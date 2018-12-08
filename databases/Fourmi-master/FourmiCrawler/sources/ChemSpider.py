import re

from scrapy import log
from scrapy.http import Request
from scrapy.selector import Selector

from source import Source
from FourmiCrawler.items import Result


# [TODO] - Maybe clean up usage of '.extract()[0]', because of possible IndexError exception.

class ChemSpider(Source):
    """
    ChemSpider scraper for synonyms and properties
    This parser will manage searching for chemicals through the
    ChemsSpider API, and parsing the resulting ChemSpider page.
    The token required for the API should be in a configuration file
    somewhere.
    """

    website = 'http://www\\.chemspider\\.com/.*'

    search = 'Search.asmx/SimpleSearch?query=%s&token='
    structure = 'Chemical-Structure.%s.html'
    extendedinfo = 'MassSpecAPI.asmx/GetExtendedCompoundInfo?csid=%s&token='

    def __init__(self, config=None):
        """
        Initialization of ChemSpider scraper
        :param config: a dictionary of settings for this scraper, must contain 
        'reliability' key
        """
        Source.__init__(self, config)
        self.ignore_list = []
        if 'token' not in self.cfg or self.cfg['token'] == '':
            log.msg('ChemSpider token not set or empty, search/MassSpec API '
                    'not available', level=log.WARNING)
            self.cfg['token'] = ''
        self.search += self.cfg['token']
        self.extendedinfo += self.cfg['token']

    def parse(self, response):
        """
        This function is called when a Response matching the variable 
        'website' is available for parsing the Response object.
        :param response: the Scrapy Response object to be parsed
        :return: a list of Result items and Request objects
        """
        sel = Selector(response)
        requests = []
        requests_synonyms = self.parse_synonyms(sel)
        requests.extend(requests_synonyms)
        requests_properties = self.parse_properties(sel)
        requests.extend(requests_properties)

        return requests

    def parse_properties(self, sel):
        """
        This function scrapes the Experimental Data and Predicted ACD/Labs tabs
        :param sel: a Selector object of the whole page
        :return: a list of Result items
        """
        properties = []

        properties.extend(self.parse_acdlabstab(sel))
        properties.extend(self.parse_experimentaldatatab(sel))

        return properties

    def parse_acdlabstab(self, sel):
        """
        This function scrapes the 'Predicted ACD/Labs tab' under Properties
        :param sel: a Selector object of the whole page
        :return: a list of Request objects
        """
        properties = []

        td_list = sel.xpath('.//table[@id="acdlabs-table"]//td').xpath(
            'normalize-space(string())')
        prop_names = td_list[::2]
        prop_values = td_list[1::2]
        for (prop_name, prop_value) in zip(prop_names, prop_values):
            # [:-1] is to remove the colon at the end, [TODO] - test for colon
            prop_name = prop_name.extract().encode('utf-8')[:-1]
            prop_value = prop_value.extract().encode('utf-8')
            prop_conditions = ''

            # Test for properties without values, with one hardcoded exception
            if (not re.match(r'^\d', prop_value) or
                    (prop_name == 'Polarizability' and prop_value == '10-24cm3')):
                continue

            m = re.match(r'(.*) \((.*)\)', prop_name)
            if m:
                prop_name = m.group(1)
                prop_conditions = m.group(2)

            m = re.match(r'(.*) at (.*)', prop_value)
            if m:
                prop_value = m.group(1)
                prop_conditions = m.group(2)

            new_prop = self.newresult(
                attribute=prop_name,
                value=prop_value,
                source='ChemSpider Predicted - ACD/Labs Tab',
                conditions=prop_conditions
            )
            properties.append(new_prop)

        return properties

    def parse_experimentaldatatab(self, sel):
        """
        This function scrapes Experimental Data tab, Physico-chemical 
        properties in particular.
        :param sel: a Selector object of the whole page
        :return: a list of Result items
        """
        properties = []

        scraped_list = sel.xpath('.//li[span="Experimental Physico-chemical '
                                 'Properties"]//li/table/tr/td')
        if not scraped_list:
            return properties
        # Format is: property name followed by a list of values
        property_name = scraped_list.pop(0).xpath(
            'span/text()').extract()[0].rstrip()
        for line in scraped_list:
            if line.xpath('span/text()'):
                property_name = line.xpath('span/text()').extract()[0].rstrip()
            else:
                new_prop = self.newresult(
                    attribute=property_name[:-1],
                    value=line.xpath('text()').extract()[0].rstrip(),
                    source=line.xpath('strong/text()').extract()[0].rstrip(),
                )
        properties.append(new_prop)

        return properties

    def parse_synonyms(self, sel):
        """
        This function scrapes the list of Names and Identifiers
        :param sel: a Selector object of the whole page
        :return: a list of Requests
        """
        requests = []
        synonyms = []

        # Exact type for this is unknown, but equivalent to Validated by Expert
        for syn in sel.xpath('//p[@class="syn"][span[@class="synonym_cn"]]'):
            name = syn.xpath('span[@class="synonym_cn"]/text()').extract()[0]
            synonyms.append(self.new_synonym(syn, name, 'expert'))
        # These synonyms are labeled by ChemSpider as "Validated by Experts"
        for syn in sel.xpath('//p[@class="syn"][strong]'):
            name = syn.xpath('strong/text()').extract()[0]
            synonyms.append(self.new_synonym(syn, name, 'expert'))
        # These synonyms are labeled by ChemSpider as "Validated by Users"
        for syn in sel.xpath(
                '//p[@class="syn"][span[@class="synonym_confirmed"]]'):
            name = syn.xpath(
                'span[@class="synonym_confirmed"]/text()').extract()[0]
            synonyms.append(self.new_synonym(syn, name, 'user'))
        # These syonyms are labeled as "Non-validated" and assumed unreliable
        for syn in sel.xpath('//p[@class="syn"][span[@class=""]]'):
            name = syn.xpath('span[@class=""]/text()').extract()[0]
            synonyms.append(self.new_synonym(syn, name, 'nonvalidated'))

        # [TODO] - confirm if English User-Validated synonyms are OK too
        for syn in synonyms:
            if syn['category'] == 'expert' and syn['language'] == 'English':
                log.msg('CS emit synonym: %s' % syn['name'], level=log.DEBUG)
                self._spider.get_synonym_requests(syn['name'])

        return requests

    def new_synonym(self, sel, name, category):
        """
        This function scrapes for a single synonym at a given HTML tag
        :param sel: a Selector object of the given HTML tag
        :param name: the name of the synonym in the tag
        :param category: the name of the category the synonym is labeled as
        :return: a dictionary containing data on the synonym
        """
        self.ignore_list.append(name)
        language = sel.xpath('span[@class="synonym_language"]/text()')
        if language:
            # The [1:-1] is to remove brackets around the language name
            language = language.extract()[0][1:-1]
        else:
            # If language is not given, English is assumed, [TODO] - confirm
            language = 'English'
        log.msg('CS synonym: %s (%s) (%s)' % (name, category, language),
                level=log.DEBUG)
        references = []
        # A synonym can have multiple references, each optionally with link
        for ref in sel.xpath('span[@class="synonym_ref"]'):
            refname = ref.xpath('normalize-space(string())')
            references.append({
                'name': refname.extract()[0][1:-1],
                'URI': ''
            })
        for ref in sel.xpath('a[@class="synonym_ref"]'):
            references.append({
                'name': ref.xpath('@title').extract()[0],
                'URI': ref.xpath('@href').extract()[0]
            })
        for ref in references:
            log.msg('CS synonym ref: %s %s' % (ref['name'], ref['URI']),
                    level=log.DEBUG)
        synonym = {
            'name': name,
            'category': category,
            'language': language,
            'references': references
        }
        return synonym

    def parse_extendedinfo(self, response):
        """
        This function scrapes data from the ChemSpider GetExtendedCompoundInfo 
        API, if a token is present in the configuration settings
        :param response: a Response object to be parsed
        :return: a list of Result items
        """
        sel = Selector(response)
        properties = []
        names = sel.xpath('*').xpath('name()').extract()
        values = sel.xpath('*').xpath('text()').extract()
        for (name, value) in zip(names, values):
            result = self.newresult(
                attribute=name,
                value=value,  # These values have no unit!
                source='ChemSpider ExtendedCompoundInfo',
            )
            if result['value']:
                properties.append(result)
        return properties

    def newresult(self, attribute, value, conditions='', source='ChemSpider'):
        """
        This function abstracts from the Result item and provides default 
        values.
        :param attribute: the name of the attribute
        :param value: the value of the attribute
        :param conditions: optional conditions regarding the value
        :param source: the name of the source if it is not ChemSpider
        :return: A Result item
        """
        return Result({
            'attribute': attribute,
            'value': value,
            'source': source,
            'reliability': self.cfg['reliability'],
            'conditions': conditions
        })

    def parse_searchrequest(self, response):
        """
        This function parses the initial response of the ChemSpider Search API
        Requires a valid token to function.
        :param response: the Response object to be parsed
        :return: A Request for the information page and a Request for the 
        extendedinfo API call
        """
        sel = Selector(response)
        log.msg('chemspider parse_searchrequest', level=log.DEBUG)
        sel.register_namespace('cs', 'http://www.chemspider.com/')
        csids = sel.xpath('.//cs:int/text()').extract()
        if len(csids) == 0:
            log.msg('ChemSpider found nothing', level=log.ERROR)
            return
        elif len(csids) > 1:
            log.msg('ChemSpider found multiple substances, taking first '
                    'element', level=log.DEBUG)
        csid = csids[0]
        structure_url = self.website[:-2].replace("\\", "") + self.structure % csid
        extendedinfo_url = self.website[:-2].replace("\\", "") + self.extendedinfo % csid
        log.msg('chemspider URL: %s' % structure_url, level=log.DEBUG)
        return [Request(url=structure_url,
                        callback=self.parse),
                Request(url=extendedinfo_url,
                        callback=self.parse_extendedinfo)]

    def new_compound_request(self, compound):
        """
        This function is called when a new synonym is returned to the spider 
        to generate new requests
        :param compound: the name of the compound to search for
        """
        if compound in self.ignore_list or self.cfg['token'] == '':
            return None
        searchurl = self.website[:-2].replace("\\", "") + self.search % compound
        log.msg('chemspider compound', level=log.DEBUG)
        return Request(url=searchurl, callback=self.parse_searchrequest)

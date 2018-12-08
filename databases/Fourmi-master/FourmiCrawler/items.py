# For more information on item definitions, see the Scrapy documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

from scrapy.item import Item, Field


class Result(Item):
    attribute = Field()
    value = Field()
    source = Field()
    reliability = Field()
    conditions = Field()

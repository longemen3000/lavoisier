# Compound Database

This folder should have the compound database. using a web crawler, we intend to extract the necessary data from Pubchem, NIST, ChemSpider and Wikipedia (for more information about the scrapper, visit [his page](https://github.com/Dekker1/Fourmi))

Once we have the results, the data shall be ordered and stored in a HDF5 file for future use. Finally, we'll build a CAPE-OPEN conector, to build a material object from the search results.
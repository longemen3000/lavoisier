# Compound Database

This folder should have the compound database. The idea is to recolect critical data with priority, of the main compounds used. web crawlers, and literal excel tables shall be used if neccesary. For predictions, a separate database with the same columns as the original shall be made. COSMO-RS and unifac methods can provide excellent estimation of properties. For quantum chemistry aproximations (COSMO-RS) the databases provided by https://www.design.che.vt.edu/VT-Databases.html are extremely important. 

Once we have the results, the data shall be ordered and stored in a sqlite3 file for future use. Finally, we'll build a CAPE-OPEN conector, to build a material object from the search results.

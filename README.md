# Work from home

Working from home (also referred to as working remotely) has long been seen as s job perk, reducing commute time and adding flexibility for the employee. However, there is little information about which jobs can even been performed remotely. There are several classification schemes for jobs, including ISCO-08 being used by the official statistical institutes in the EU, and elaborate ontologies such as ESCO and O\*net. None of these include explicit information about to what extent the jobs can be performed from home. A recent paper (https://www.nber.org/papers/w26948.pdf) explored the O\*net ontology and estimated the percentage of american jobs that could be performed from home, based on the job description in the O\*net ontology and labor data from BLS.

Norwegian labor market data is centered around the 4-digit ISCO-08 standard (and a few variants). Like many statistical standards, ISCO-08 has a hierarcical composition where the first digit (0-9) roughly corresponds to the level of education expected (but not necessarily required) of a person in the profession, and each subsequent digit adds a detail to what type of work the job entails. This way, data can be aggregated on the 1-digit, 2-digit or 3-digit level, depending on the level of granularity that is required. These occupational codes are used by employers when reporting labor statistics, and by the LCS survey.

In order to explore the prevalence of remote work in Norway (both in normal times and in COVID-19 times), we have to augment the ISCO standard with some estimate of how easy it is for the specific jobs to be carried out from a home office.

Here, we are comparing the results of two strategies for doing this: Manual augmentation and text matching in job ads.

## Manual augmentation
The ISCO standard is published by the international labor organization (ILO), and the documentation includes more specific descriptions of each occupation, including specific tasks that the occupation typically includes.

Using these descriptions, we used crowdsourcing to create a categorization of wether the job could be performed from home. Each description was annotated by 5 different (amateur) annotators, which resulted in a trinary categorization of occupations based on the description: "Remote-friendly", "not remote-friendly", and "Unknown". The latter category is intended to prevent occupations to randomly be categorized into one or the other group in cases where the job description does not provide sufficien information.

## Text matching in job ads
The Norwegian welfare administration publishes full job ads in a machine readable format, and makes arkives of these ads publically available. Personal information (names, phone numbers etc) have been removed from the ads, but the ads are otherwise complete. Data from this source is available as far back as 2002, but the generating algorithm for the data has changed significantly. At its outset, it was intended as a digitized verison of a job board, where terse job descriptions were posted together with contact information for further inquiries. In 2019, it was a farily comprehensive source covering practically all jobs that were advertised - with the exception of the solitary "help wanted" signs some stores place in their window. There is a jump in the data in 2018 as the NAV picked up more sources of ads from temp-agencies.

Also, needless to mention, a data set of job ads can by definition not cover vacancies that were not advertised. As the purpose of this analysis is to reason about the workforce, this is an additional source of bias.

Using the job text, we searched for ads mentioning being remote friendly (the norwegian term "hjemmekontor" is a precise indicator, but we also tried adding a few other common phrases). This approach is unquestionably very crude, but nonetheless informative and readily available.

## Results

We find that although the two ways of measuring the possibilities for working remotely are vastly different and both prone to errors, they produce generally similar results.

Roughly 34% of the actual jobs in Norway can be performed from home. This is quite similar to the NBER paper, and the numbers are concentrated in the academic end of the ISCO scale.
# Ohio-Voter-File-Visualization

This month, I set out to take political data and build an interactive visualization.

Here is how I built my dataset:

-Obtain publicly-available Ohio voter file data to get party affiliation, voting record, congressional district, and zip code for each voter.
-Obtain publicly-available zip code level income data. Get the average income for each zip code and assume that each voter in the district makes that income.
-Obtain publicly-available Congressional and state senator representation data. Identify if each voter is represented by a Democrat or Republican.
-Calculate the number of times each voter has cast a ballot in the last five elections.

I used R to do my data manipulation. Then I downloaded Tableau Public, which is free up to 10GB of storage, and published on Tableau's servers. It looks at voter turnout across different variable groups, with the same variable groups serving as filters.

A few cool findings:

Registered Democrats represented by Republicans (in Congress) turned out at higher rates than those represented by Democrats (~87 percent vs ~86 percent). This makes sense as they would be more fired up to vote.
Independent (non-party affiliated) voters turned out at much lower rates than party-affiliated voters. Independents turned out at ~36 percent, while both Democrats and Republicans turned out at ~86 percent). Those who select a party are more loyal and invested in the process.
Older and wealthier voters turned out at much higher rates. Those in a zip code with average income of $100k or more voted at 67 percent, while those in zip codes of average income of $50k or less voted at 51 percent. Seniors voted at a rate of 77 percent, while under-30’s voted at a rate of 32 percent.
Overall, this was a very insightful month and I’m glad I got to work through all this.

# SQL Server Data Discovery Tool Preview

Hello!

I’ve seen a lot of posts and questions about how to search for actual data across a database and I wanted to share a SQL script I built that solved that exact problem for me.

I have dealt with many databases that were large and undocumented, so finding out where anything was kept was a pain. So I started writing this script and have been trying to improve it ever since. I wanted to share it with others who were going through similar issues.

Keep in mind: this tool is best suited for situations where you have many tables and columns and don’t know where a specific value is stored. Querying large, unindexed tables will still carry performance risks, so apply filters wisely!

## Why I Built It

From what I’ve seen, there are scripts out there that use dynamic SQL and cursors to run similarly, but the main issues I see with those are:

- Slow — They check every column everywhere, even where it doesn’t make sense
- Resource-heavy — They query full tables, which tanks performance
- Limited — They don’t support multi-database search or custom filters

So I made the following adjustments:

- There are data type, schema, table and column filters so that when you define the type of data you are searching for, it will filter out any unneeded tables and columns so it doesn’t waste time checking for data where it wouldn’t be. Significantly cuts down the time it takes to search large databases.
- Use filters wisely! While this tool is good for narrowing down where data can be found, large unindexed tables might still be a performance concern.
- I tried making it customizable and able to work on any server. It is also able to search multiple databases on the same server to save time when trying to find where your data is

Here is a screenshot of what you would need to enter. All variables are at the top of the script and you would just need to fill those out and then execute.
This is an example of a search you could do in the AdventureWorks2022 database. It will search every column with “name” in it for the string “Like ‘%Mark%’”.

## Input Example
![Inputs Example](Preview%20Example%20Input.png)

## Results Window (Query Time: 00:00:01)
![Results Example](Preview%20Example%20Results.png)

Each match will show you:
- The database, table, and column where the value was found
- A ready-to-copy query
- A preview of the matching rows
- A summary of how many databases, tables, and columns were checked

This script was built on SQL Server 2019 and tested across 6+ servers and 30+ databases.

## Full Version

There is also a full version of this script available for anyone who finds this script useful.
It includes:
- Setting the row limit for max rows pulled per table
- Additional Criteria to add to your search (i.e. DepartmentID = 10)
- Additional Date Criteria to add (i.e. ChangedDate = '2025-05-20')
- Search Exact Column Names
- Search Exact Table Names

This is just for anyone who finds the tool useful, would like some extra features and would like to support me.

## LINK TO FULL VERSION HERE:
https://brb2828.gumroad.com/

## Feedback Welcome
This is the first tool I’ve ever released publicly. If you use it and have feedback, ideas, or just want to say it helped, I’d genuinely love to hear it. I want this to keep evolving and help others save time too.

# Social_Media_SqlServer_Database
This is a database designed to support a Social Media application, coded for SQL Server 2016 or later.

The intention of this Social Media Application was to let consumers have more choices, by enabling every business however small to reach consumers.
In other words, to allow stores with unique inventory to reach to wider audiences, to empower consumers with a wider range of choices and to allow rather small business to thrive.


## Project Description
Here is a non-exhaustive list of actions and features of the Social Media application that are supported by this database design:
1. Non-invasive IP tracking to display things pertinent to the user's geography.
2. User subscription with e-mail confirmation, captcha, and basic registration info.
3. User setup: avatar, background display, description, name/nickname, location, and contact information.
4. Allow users to load images and keep a gallery of images to be used in postings, responses, avatars and background displays.
5. Allow users to make public Postings including header, text body, images, and a price tag in different currencies.
6. Target those postings to users based users current location, custom location preferences, and 
7. Browsing postings by geography and interests. User subscription to specific geographies and interests.
8. Users subscription ("following") other users. Always see their postings.
9. Reply to public postings, making the thread private.
10. Notify the user when a user responds to a thread.
11. Allow users to abandon a thread, and make it visually evident to the other user when a conversation has been abandoned.

Note:
All Stored Procedures that return data to the application automatically encode the information to a JSON string.


## Description of codebases.
The social Media application has 4 layers:
1. Front-End (HTML/CSS/Javascript/extensive use of JQuery)
2. Back-end in C# .Net Core 2~3 to dispense or post data (postings, offers, new user configuration, user session, img urls, etc)
3. (***THIS CODEBASE***) A database to support all of the application data, except media. Compatible with SQL Server 2016 or later, or Azure SQL.
4. Azure Blob Storage for images and other media. The back-end is especially adjusted to work with AzBS, but could be tweaked to use S3 or others.
5. Xamarin for phone (planned only)


## Caveats
However complete this is (at least 95% of what I expected it to be), there is some hard-coding which I didn't intend to leave.
These shall be addressed if no 


## How to Use the Project
The database is 100% compatible with SQL Server 2016 or later, or Azure SQL. 
Backwards compatibility cannot be warranted.

The database has a lot of Foreign Key dependencies that I knew by heart when I developed it, and without a Visual Studio project to deploy a DACPAC.
To deploy it, an experienced SQL Server developer will be necessary.

If you're not sure where to start, I'd suggest you get in touch with me on LinkedIn:
https://www.linkedin.com/in/homero-e-rivera/


## Created by
Homero Rivera


## License
MIT License

Copyright (c) 2023 Homero Enrique Rivera Diaz

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
# ExpenseTracker

A native iOS Application developed to as a solution to the problem of finance tracking and management. The application is written in swift and iOS Storyboarding
along with the use of various services and frameworks such as Cocoa, iOS Charts, PDFKit, Vision and OCR, ChatGPT API along with the use of SQLite Database for presistant data storage. 
Currently only available in English. The requirements for the application was devised from thorough market research and a user driven iterative development lifecycle was maintained 
throughout the timeline of the project. Upon implementation of a set of functionalities, users were consulted and based on feedback, various improvements
to exisiting functionalties and addition of newer ones were incorporated into the application. The appliaction, at the current stage, sits at the
3rd iteration. 

# Functionalities
- ## Minimalistic and Simplified UI Design
The application was designed to be simple to use and not having any complex UI features. A tab based naviation allows easier traversing across
various sections of the application. All views consist of simplified UI elements to provide for both faster adaptability in using the app along
with easier accessability and easier usability.

- ## Adding Expenses
Users can add expenses into the system by accessing the Add Expense form and adding various data regarding their expenses. Upon submitting the form,
the expense is added into a persistance storage for future referencing and analytics.

- ## Save Photo of Expenditure Documents
Users can capture an image of expense documents (receipt, invoice, etc) in order to keep a record along with an expense that they intend to add into
the system. This functionality in available withint the form itself where the user can tap on the image box which opens up the camera and they can
take an image, crop and add it to the expense. 
**(IMPORTANT : This functionality requires an actual device since emulators tend not to have cameras and requires user permission to use the camera function of their device)**

- ## Expenses List and Detailed Expenses View
THe user can view a list of all expenses added to the system with the date of the expenditure, cateogory and amount spent in a tabulature form. Upon
clicking any of the items in the list, users are navigated to a view where they can view the details for the expense along with any images they saved.

- ## Extensive Expenditure Analytics
Based on the added expenditures, users are provided with trends of their expenditure in the overview tab (landing page) of the application. Users
are provided with a series of 5 different Charts with their respective analytics.
- ### Monthly Percentile Expenses (Pie Chart)
- ### Top 3 Expenses (Bar Chart, max of 4 bars)
- ### Count of Each Expense Category (Bar Chart)
- ### Daily Total Expenses (Scatter Chart)
- ### Cumulative Expense (Line Graph)
The charts are projected in a horizontal scroll view, upon swifing users can traverse between the charts. All charts are interactive and respective data is
presented on a table below which is scrollable.

- ## Mostly Expenditure Threshold
Users can set a monthly expenditure threshold in the settings page in order to allow the system to alert them in keeping track of their expenses for
the current month. The expense cap is also brought in and displayed in the cumulative expense line graph.

- ## Alerts and Alerts List
Based on the threshold that users set, users are notified once they are nearly reaching their threshold. The alert keeps generating if users keep
adding expenditures and the sum exceeds the threshold. The alerts are displayed in a tabulature format with each alert depicting the date of the
alert, the total amount spent by the user for that particular month, and the amount left to be spent for the month based on the threshold. The
alerts are in-app. Alerts have also been configured to be displayed in the lockscreen along with the ability for users to opt in and out of alerts directly
from the settings.

- ## Expense Reports
From the settings section of the application, users can generate expenditure reports based on a certain date range. Users can select a range of date 
by interacting with the two date pickets and upon tapping the generate report button, a pdf report is generated with all expenses that from the selected
date range and users can download the pdf or share it with others via other applications, email or even print.

- ## Smart Expense Advisor
An AI powered chat-based Smart Assistant is also provided along with the application. The Smart Advisor is capable of providing savings advice and other expenditure related advice
based on the user's expenditure trends and patterns. Moreover, the advisor can also provide anlysis on the user's expenditure data and can simply present all of selected expenses based
on the users query.

- ## All Device Support and Dark Mode
The application's UI layout has been carefully desgined in order for it to work flawlessly across all Apple Devices and it also includes support for 
Dark Mode.

# Future Upgrades
- Authentication (Signup, Signin)
- Cloud-based Database
- Customizable Analytics (Chart Selection, Specific Expense Data Selection, Analysis Type Selection)
- Allow capture of both expense category and payment method directly from the captured image (i.e. ML model training)
- Recent Expenditures
- Customizable Reports (i.e. specific Expense category selection)
- More Language Support

 # Application Demo:
 A short gif demonstrating the game in action: <br/>
 <br/>
 <br/>
 ![](FullExpenseTrackerDemo.gif)
 <br/>
# How to Run

At the current stage, the application has not been deployed in the AppStore and hence there is no way to download it or run it natively in
a iPhone. Hence, the only way to run it is through Xcode from a Mac device and use an emulator or connect an iPhone/iPad to use the application.
Note: Open the app in XCode by clicking on the .xcworkspace.


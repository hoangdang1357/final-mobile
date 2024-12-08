# expense_tracker
## Enter Expense Information and Overall App Design 
Expense Information Fields:
Expense Date - Required.
Expense Category - Required (e.g., Food, Transportation).
Amount - Required.
Notes - Optional.
The app checks for required information and prompts users to fill in missing fields. Once all data is entered, it is displayed for confirmation and edits if needed.

## CRUD and Expense Search 
The app performs basic CRUD operations to manage expenses:
Create, Read, Update, delete: Users can add new expenses, view expense lists, edit, or delete entries.
Search: Search expenses by category or notes for easier expense tracking.

## Monthly Budget Management 
The app allows users to create monthly budgets and track total monthly expenses:
Create New Monthly Budget: Users can initiate a monthly budget.
Add or Remove Monthly Expenses: Users can add expenses to the monthly budget or remove items if needed. 
Budget Fields:
Budget Month (e.g., October 2023).
Total Expenses: Automatically calculated from monthly expenses. 

## Cloud Database Storage 
Data will be synchronized with Firestore:
Two-way Sync: Any data changes on the device automatically update the cloud, ensuring data consistency.

## Advanced Features 
Expense Analysis from AI API: AI analyzes spending habits and suggests saving strategies.

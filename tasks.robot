*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library    RPA.Robocorp.Vault
Library    RPA.Browser.Selenium    auto_close=${FALSE}
Library    RPA.HTTP
Library    RPA.PDF
Library    RPA.Tables
Library    RPA.Archive
Library    RPA.Dialogs

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Salutation
    Log Secret
    Open the robot order website
    Download orders csv
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Click modal button
        Fill the form    ${row}
        Preview the robot
        Wait Until Keyword Succeeds    3x    3s    Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Create a ZIP file of the receipts


*** Keywords ***
Salutation
    Add heading    Input your name
    Add text input    Your Name    label=Your Name
    ${result}=    Run dialog
    Log    ${result}


Log Secret
    ${secret}=    Get Secret    orderrobot
    Log    ${secret}[message]

Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order    maximized=True
    
Click modal button
    Click Element If Visible    css:#root > div > div.modal > div > div > div > div > div > button.btn.btn-dark

Download orders csv
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Get orders
    ${orders}=    Read table from CSV    orders.csv    header=True
    RETURN    ${orders}

Fill the form
    [Arguments]    ${order}
    Select From List By Value    id:head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${order}[Legs]
    Input Text    address    ${order}[Address]

Preview the robot
    Click Button    preview
    

Submit the order
    Click Button    order
    Element Should Be Visible    id:receipt

Store the receipt as a PDF file
    [Arguments]    ${name}
    Wait Until Element Is Visible    id:receipt
    ${sales_results_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${sales_results_html}    ${OUTPUT_DIR}${/}receipts${/}${name}.pdf
    RETURN    ${OUTPUT_DIR}${/}receipts${/}${name}.pdf
Take a screenshot of the robot
    [Arguments]    ${name}
    Wait Until Element Is Visible    robot-preview-image
    Screenshot    robot-preview-image    ${OUTPUT_DIR}${/}screenshots${/}${name}.png
    RETURN    ${OUTPUT_DIR}${/}screenshots${/}${name}.png
Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot_file}    ${pdf_file}
    Open Pdf    ${pdf_file}
    ${files}=    Create List
    ...    ${screenshot_file}
    Add Files To Pdf    ${files}    ${pdf_file}    append=True
    Close Pdf    ${pdf_file}
Go to order another robot
    Click Button    id:order-another

Create a ZIP file of the receipts
    Archive Folder With Zip    ${OUTPUT_DIR}${/}receipts    ${OUTPUT_DIR}${/}receipts.rar
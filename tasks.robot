*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library    RPA.Robocorp.Vault
Library    RPA.Browser.Selenium
Library    RPA.Excel.Files

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Log Secret


*** Keywords ***
Log Secret
    ${secret}=    Get Secret    order-robot
    Log    ${secret}[message]
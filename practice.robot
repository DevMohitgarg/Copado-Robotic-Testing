#
# Test asset originally created using Copado QEditor.
#

*** Settings ***

Library    QWeb

*** Test Cases ***

Testing 1
    [Documentation]    Test Case created using the QEditor

    OpenBrowser    about:blank    chrome
Login to Salesforce
    OpenBrowser        ${login_url}  chrome
    TypeText          username      ${username}
    ClickText         Log In
    TypeText          password      ${password}
    ClickText         Log In
    TypeText           Verification Code        ${verification_code}
    ClickText          Verify       
        


Create a new lead record
    ${randomLastName}=    Generate Random String    6    [LOWER]
    ${randomCompany}=     Generate Random String    6    [LOWER]
    Set Suite Variable    ${LAST_NAME}    ${randomLastName}
    Set Suite Variable    ${COMPANY}    ${randomCompany}
    ClickText    Leads
    ClickText    New
    ClickText    Last Name
    TypeText     Last Name    ${LAST_NAME}
    ClickText    Company
    TypeText     Company    ${COMPANY}
    ClickText    Save    partial_match=False

Convert a lead record
    ClickText    Leads
    ClickText    ${LAST_NAME}
    ClickText    Show more actions
    ClickText    Convert
    UseModal    On
    ClickText    Convert    partial_match=False
    UseModal    On
    UseModal    On
    ClickText    Go to Leads

Verify the account, contact and opportunity record
    ClickText    Accounts
    ClickText    ${COMPANY}
    VerifyText   ${COMPANY}
    ClickText    ${LAST_NAME}    anchor=Skip to Navigation
    ClickText    ${COMPANY}-
    VerifyText   ${COMPANY}-
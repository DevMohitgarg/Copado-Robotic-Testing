#
# Test asset originally created using Copado QEditor.
#

*** Settings ***

Library                      String
Documentation                New test suite
Library                      QForce
Library                      QWeb
Library                      Collections
Library    DateTime
# Library                    QMobile
Library                      Collections
Suite Setup                  Open Browser                about:blank                 chrome
Suite Teardown               Close All Browsers
*** Variables ***
${current_date}=

*** Test Cases ***
    OpenBrowser    about:blank    chrome
    OpenBrowser        ${login_url}  chrome
    TypeText          username      ${username}
    ClickText         Log In
    TypeText          password      ${password}
    ClickText         Log In
    TypeText           Verification Code        ${verification_code}
    ClickText          Verify 
    ${ran_string}=              Generate Random String      5
    ${current_date}=            Get Current Date            result_format=%H:%M
    ${closed_date}=             Get Current Date            increment=7 days    result_format=%m/%d/%Y
    ${opp_name}=                Catenate                    ${ran_string}               ${current_date}
    ClickText                  Opportunities
    ClickText                  New                         partial_match= False
    Sleep                      2s
    UseModal                   On
    ClickText                  Opportunity Name
    TypeText                   Opportunity Name            ${opp_name}
    Sleep                      2s
    ClickText                  Close Date
    TypeText                   Close Date                  ${closed_date}
    Sleep                      2s
    CLickText                  Stage
    PickList                   Stage                       Qualification
    Sleep                      2s
    ClickText                  Save                        partial_match= False
    ClickText                  Details
    ClickText                  xpath\=//article[@aria-label\='Products']//div[@class\='actionsContainer']
    UseModal                   On
    CLickText                  Choose Price Book           partial_match= True
    Sleep                      5s
    ClickText                  Price Book
    TypeText                   Price Book                  Standard
    ClickText                  Save                        partial_match= False
    Sleep                      2s
    ClickText                  xpath\=//article[@aria-label\='Products']//div[@class\='actionsContainer']
    ClickText                  Add Products
    ClickElement               xpath=//input[@aria-describedby='Search']
    @{product_name}            Create List                 GenWatt Diesel 1000kW       Installation: Portable      Installation: Industrial - Low
    @{product_quantity}        Create List                 1                        3                        2
    # ClickCheckbox            GenWatt Diesel 1000kW       on
    # ClickText                Next                        partial_match= False
    # UseModal                 On
    # ClickText                Quantity
    # TypeText                 Quantity                    1
    # CLickText                Save                        partial_match= False
    FOR                        ${product_item}             IN                          @{product_name}
        TypeText               Search Products             ${product_item}
        ClickElement           xpath=//lightning-icon[@icon-name='utility:search']
        ClickElement           xpath=//div[@role='listbox']
        ClickCheckbox          ${product_item}             on
    END
    Sleep                      2s
    ClickText                  Next                        partial_match= False
    FOR                        ${index}                    ${Product}                  IN ENUMERATE                @{product_name}
        ClickElement           xpath=//tr[.//a[text()='${Product}']]//button[contains(@title,'Edit Quantity')]     clicks=2
        TypeText               Quantity                    ${product_quantity}[${index}]                           anchor=${Product}
    END
    ClickText              Save
    ClickText              Products                        partial_match=False

    &{product_price}       Create Dictionary
    &{product_quantity}    Create Dictionary
    FOR    ${prod}    IN                        @{product_name}
        ${quantity}=                        Get Text       xpath\=//tr[.//a[text()\='${prod}']]//span[contains(@class,'uiOutputNumber')]
        ${sales_price}=                     Get Text       xpath\=//tr[.//a[text()\='${prod}']]//span[contains(@class,'forceOutputCurrency')]
        ${product_quantity}[${prod}]=       Set Variable    ${quantity}
        ${product_price}=                   Set Variable    ${sales_price}
    END
    ${total_amount}=    Set Variable    0
    FOR                 ${produ}        IN      @{product_name}
        ${quantity}=       Convert To Number    ${quantity}
        ${sales_price}=    Remove String    ${sales_price}    $    ,
        ${product_total}=                   Evaluate          ${quantity} * ${sales_price}
        ${total_amount}=                    Evaluate          ${total_amount} + ${product_total}
    END
    ClickElement                        xpath=//a[contains(text(),'${opp_name}')]
    CLickText                        Details
    ${opportunity_amount}=           Get Text                 xpath\=//sfa-output-opportunity-amount[@slot\='outputField']
    ${opportunity_amount}=    Remove String    ${opportunity_amount}    $    ,
    ${opportunity_amount}     Convert To Number                        ${opportunity_amount}
    IF    ${total_amount} == ${opportunity_amount}
        Log To Console        Product Total And Opportunity Amount Are Equal
    ELSE
        Log    Product Total and Opportunity Amount are NOT equal
        END


# Create a new lead record
#     ${randomLastName}=    Generate Random String    6    [LOWER]
#     ${randomCompany}=     Generate Random String    6    [LOWER]
#     Set Suite Variable    ${LAST_NAME}    ${randomLastName}
#     Set Suite Variable    ${COMPANY}    ${randomCompany}
#     ClickText    Leads
#     ClickText    New
#     ClickText    Last Name
#     TypeText     Last Name    ${LAST_NAME}
#     ClickText    Company
#     TypeText     Company    ${COMPANY}
#     ClickText    Save    partial_match=False

# Convert a lead record
#     ClickText    Leads
#     ClickText    ${LAST_NAME}
#     ClickText    Show more actions
#     ClickText    Convert
#     UseModal    On
#     ClickText    Convert    partial_match=False
#     UseModal    On
#     UseModal    On
#     ClickText    Go to Leads

# Verify the account, contact and opportunity record
#     ClickText    Accounts
#     ClickText    ${COMPANY}
#     VerifyText   ${COMPANY}
#     ClickText    ${LAST_NAME}    anchor=Skip to Navigation
#     ClickText    ${COMPANY}-
#     VerifyText   ${COMPANY}-
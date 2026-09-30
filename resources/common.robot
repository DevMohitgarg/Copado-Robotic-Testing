*** Settings ***
Library     QWeb
Library     QForce
Library     String
Library     DateTime
Library     Collections

*** Variables ***
${BROWSER}          chrome
${APP}              Service
# ${LOGIN_URL}        ${EMPTY}     # supplied by CRT job variables / secrets
# ${SF_USERNAME}      ${EMPTY}
# ${SF_PASSWORD}      ${EMPTY}
${SHORT}            10s
${LONG}             30s

*** Keywords ***
Setup Browser
    [Documentation]    Suite setup: open browser, log in, launch the Service app.
    Set Library Search Order    QForce    QWeb
    Open Browser    about:blank    ${BROWSER}
    SetConfig       DefaultTimeout    ${LONG}
    Login To Salesforce
    LaunchApp       ${APP}

Login To Salesforce
    GoTo        ${LOGIN_URL}
    TypeText    Username    ${SF_USERNAME}
    TypeSecret  Password    ${SF_PASSWORD}
    ClickText   Log In
    TypeText    Verification code    ${verification_code}
    ClickText                        Log In
    VerifyText  Home        timeout=${LONG}

End Suite
    Close All Browsers

Return To Cases List
    LaunchApp    ${APP}
    ClickText    Cases
    VerifyText   Recently Viewed    timeout=${SHORT}

Build Case Data
    [Documentation]    Dynamic data: returns a fresh dictionary on every call (no shared or hard-coded data).
    [Arguments]    ${priority}=Medium    ${origin}=Phone    ${prefix}=AUTO
    ${stamp}=    Get Current Date    result_format=%Y%m%d-%H%M%S
    ${sfx}=      Generate Random String    6    [UPPER][NUMBERS]
    ${data}=     Create Dictionary
    ...    subject=${prefix}-${stamp}-${sfx}
    ...    description=Automated case ${prefix}-${sfx}
    ...    priority=${priority}
    ...    origin=${origin}
    ...    contact_first=Auto
    ...    contact_last=Tester${sfx}
    ...    contact_email=auto.${sfx}@example.com
    RETURN    ${data}
*** Settings ***
Documentation    Copado Robotic Testing – Salesforce Case Management (single-file suite)
Library          QWeb
Library          QForce
Library          String
Library          DateTime
Library          Collections
Suite Setup      Setup Browser
Suite Teardown   End Suite
Test Teardown    Run Keywords    Capture Debug Info On Failure    ${TEST NAME}    AND    Delete Current Case

*** Variables ***
${BROWSER}          chrome
${APP}              Service
# --- IMPORTANT: set these 3 as CRT Job Variables / Secrets, NOT here ---
${LOGIN_URL}        ${EMPTY}
${SF_USERNAME}      ${EMPTY}
${SF_PASSWORD}      ${EMPTY}
${SHORT}            10s
${LONG}             30s
${CASE}             ${EMPTY}
${CASE_URL}         ${EMPTY}

*** Test Cases ***
TC001 Create Case With Dynamic Data
    [Tags]    case-mgmt    smoke    critical    TC001
    ${CASE}=    Build Case Data
    Set Test Variable    ${CASE}
    Create Case    ${CASE}
    VerifyText     ${CASE}[subject]
    VerifyField    Priority    ${CASE}[priority]

TC002 Case Appears In List View
    [Tags]    case-mgmt    smoke    TC002
    ${CASE}=    Build Case Data    priority=High
    Set Test Variable    ${CASE}
    Create Case    ${CASE}
    Open Case By Subject    ${CASE}[subject]

TC101 Full Case Lifecycle
    [Tags]    case-mgmt    regression    e2e    TC101
    ${CASE}=    Build Case Data    priority=High    origin=Phone
    Set Test Variable    ${CASE}
    Create Case          ${CASE}
    Update Case Status   Working
    Add Case Comment     Investigating ${CASE}[subject]
    Escalate Case
    Close Case

TC102 Status Progression
    [Tags]    case-mgmt    regression    TC102
    FOR    ${status}    IN    Working    Escalated    Closed
        Verify Status Change    ${status}
    END

TC201 Cannot Save Case Without Required Fields
    [Tags]    case-mgmt    negative    TC201
    Return To Cases List
    ClickText     New
    UseModal      On
    ClickText     Save    partial_match=False
    VerifyText    Complete this field    timeout=${SHORT}
    ClickText     Cancel
    UseModal      Off

*** Keywords ***
# ---------- Setup / Teardown ----------
Setup Browser
    [Documentation]    Suite setup: validate config, open browser, log in, launch Service app.
    Validate Required Variables
    Set Library Search Order    QForce    QWeb
    Open Browser    about:blank    ${BROWSER}
    SetConfig       DefaultTimeout    ${LONG}
    Login To Salesforce
    LaunchApp       ${APP}

Validate Required Variables
    [Documentation]    Fails fast with a clear message if job variables/secrets are missing.
    Run Keyword If    '${LOGIN_URL}' == '${EMPTY}'
    ...    Fail    LOGIN_URL is not set. Set it as a CRT job variable before running.
    Run Keyword If    '${SF_USERNAME}' == '${EMPTY}'
    ...    Fail    SF_USERNAME is not set. Set it as a CRT job variable/secret before running.
    Run Keyword If    '${SF_PASSWORD}' == '${EMPTY}'
    ...    Fail    SF_PASSWORD is not set. Set it as a CRT job secret before running.

Login To Salesforce
    GoTo        ${LOGIN_URL}
    TypeText    Username    ${SF_USERNAME}
    TypeSecret  Password    ${SF_PASSWORD}
    ClickText   Log In
    VerifyText  Home        timeout=${LONG}

End Suite
    Close All Browsers

# ---------- Dynamic Data ----------
Build Case Data
    [Documentation]    Returns a fresh dictionary on every call (no shared or hard-coded data).
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

# ---------- Navigation ----------
Return To Cases List
    LaunchApp    ${APP}
    ClickText    Cases
    VerifyText   Recently Viewed    timeout=${SHORT}

# ---------- Business Keywords ----------
Create Case
    [Arguments]    ${data}
    Log Step       Create case ${data}[subject]
    Return To Cases List
    ClickText      New
    UseModal       On
    PickList       Priority       ${data}[priority]
    PickList       Case Origin    ${data}[origin]
    TypeText       Subject        ${data}[subject]
    TypeText       Description    ${data}[description]
    ClickText      Save           partial_match=False
    UseModal       Off
    VerifyText     was created    timeout=${SHORT}
    ${url}=        GetUrl
    Set Test Variable    ${CASE_URL}    ${url}

Open Case By Subject
    [Arguments]    ${subject}
    Return To Cases List
    TypeText       Search this list...    ${subject}
    PressKey       Search this list...    {ENTER}
    ClickText      ${subject}
    VerifyText     Case Information    timeout=${SHORT}

Update Case Status
    [Arguments]    ${status}
    Log Step       Move case to ${status}
    ClickText      Edit    anchor=Case Information
    UseModal       On
    PickList       Status    ${status}
    ClickText      Save    partial_match=False
    UseModal       Off
    VerifyField    Status    ${status}

Add Case Comment
    [Arguments]    ${text}
    ClickText      Feed
    ClickText      Share an update...
    TypeText       Share an update...    ${text}
    ClickText      Share
    VerifyText     ${text}

Escalate Case
    Log Step       Escalate case
    ClickText      Edit    anchor=Case Information
    UseModal       On
    ClickCheckbox  Escalated    on
    ClickText      Save    partial_match=False
    UseModal       Off
    VerifyText     Escalated

Close Case
    Update Case Status    Closed

Verify Status Change
    [Arguments]    ${status}
    ${CASE}=    Build Case Data
    Set Test Variable    ${CASE}
    Create Case          ${CASE}
    Update Case Status   ${status}

Delete Current Case
    [Documentation]    Teardown cleanup so the sandbox stays clean.
    Run Keyword If    '${CASE_URL}' != '${EMPTY}'    Run Keyword And Ignore Error    GoTo    ${CASE_URL}
    Run Keyword If    '${CASE_URL}' != '${EMPTY}'    Run Keyword And Ignore Error    ClickText    Delete
    Run Keyword If    '${CASE_URL}' != '${EMPTY}'    Run Keyword And Ignore Error    ClickText    Delete    anchor=Cancel

# ---------- Debug / Reporting ----------
Capture Debug Info On Failure
    [Documentation]    Adds evidence to the CRT report only when a test fails.
    [Arguments]    ${test_name}
    Run Keyword If Test Failed    Collect Failure Evidence    ${test_name}

Collect Failure Evidence
    [Arguments]    ${test_name}
    ${url}=      GetUrl
    ${title}=    GetTitle
    Log    FAILED TEST: ${test_name}    level=ERROR
    Log    Page URL: ${url}    level=ERROR
    Log    Page title: ${title}    level=ERROR
    Log    Test data used: ${CASE}    level=ERROR
    LogScreenshot
    Run Keyword And Ignore Error    LogPage
    Run Keyword And Ignore Error    Dismiss Any Modal

Dismiss Any Modal
    ${present}=    Run Keyword And Return Status    IsText    Cancel    timeout=2s
    Run Keyword If    ${present}    ClickText    Cancel
    UseModal    Off

Log Step
    [Arguments]    ${message}
    Log    >>> STEP: ${message}    console=True
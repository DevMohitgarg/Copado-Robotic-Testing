*** Settings ***
Library     QWeb
Library     QForce
Resource    common.robot
Resource    debug.robot

*** Keywords ***
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

Delete Current Case
    [Documentation]    Teardown cleanup so the sandbox stays clean.
    Run Keyword If    '${CASE_URL}' != ''    Run Keyword And Ignore Error    GoTo    ${CASE_URL}
    Run Keyword If    '${CASE_URL}' != ''    Run Keyword And Ignore Error    ClickText    Delete
    Run Keyword If    '${CASE_URL}' != ''    Run Keyword And Ignore Error    ClickText    Delete    anchor=Cancel
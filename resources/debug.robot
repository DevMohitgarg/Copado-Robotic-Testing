*** Settings ***
Library     QWeb
Library    QForce

*** Variables ***
${CASE}         ${EMPTY}
${CASE_URL}     ${EMPTY}

*** Keywords ***
Capture Debug Info On Failure
    [Documentation]    Test teardown: adds evidence to the CRT report only on failure.
    Run Keyword If Test Failed    Collect Failure Evidence

Collect Failure Evidence
    ${url}=      GetUrl
    ${title}=    GetTitle
    Log          FAILED TEST   : ${TEST NAME}     level=ERROR
    Log          Page URL      : ${url}           level=ERROR
    Log          Page title    : ${title}         level=ERROR
    Log          Test data used: ${CASE}          level=ERROR
    LogScreenshot
    Run Keyword And Ignore Error    LogPage
    Run Keyword And Ignore Error    Dismiss Any Modal

Dismiss Any Modal
    ${present}=    Run Keyword And Return Status    IsText    Cancel    timeout=2s
    Run Keyword If    ${present}    ClickText    Cancel
    UseModal    Off

Log Step
    [Arguments]    ${message}
    [Documentation]    Breadcrumbs so the report shows which business step broke.
    Log    >>> STEP: ${message}    console=True
*** Settings ***
Documentation    Regression: end-to-end journey New -> Working -> Escalated -> Closed.
Resource         ../resources/common.robot
Resource         ../resources/case_keywords.robot
Suite Setup      Setup Browser
Suite Teardown   End Suite
Test Teardown    Run Keywords    Capture Debug Info On Failure    AND    Delete Current Case
Test Tags       case-mgmt    regression

*** Test Cases ***

TC101 Full Case Lifecycle
    [Tags]    e2e    TC101
    ${CASE}=    Build Case Data    priority=High    origin=Phone
    Set Test Variable    ${CASE}
    Create Case          ${CASE}
    Update Case Status   Working
    Add Case Comment     Investigating ${CASE}[subject]
    Escalate Case
    Close Case

TC102 Status Progression
    [Tags]    TC102
    [Template]    Verify Status Change
    Working
    Escalated
    Closed

*** Keywords ***
Verify Status Change
    [Arguments]    ${status}
    ${CASE}=    Build Case Data
    Set Test Variable    ${CASE}
    Create Case          ${CASE}
    Update Case Status   ${status}
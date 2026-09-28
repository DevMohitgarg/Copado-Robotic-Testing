*** Settings ***
Documentation    Smoke: fast critical-path checks (run on every deployment).
Resource         ../resources/common.robot
Resource         ../resources/case_keywords.robot
Suite Setup      Setup Browser
Suite Teardown   End Suite
Test Teardown    Run Keywords    Capture Debug Info On Failure    AND    Delete Current Case
Force Tags       case-mgmt    smoke

*** Test Cases ***
TC001 Create Case With Dynamic Data
    [Tags]    critical    TC001
    ${CASE}=    Build Case Data
    Set Test Variable    ${CASE}
    Create Case    ${CASE}
    VerifyText     ${CASE}[subject]
    VerifyField    Priority    ${CASE}[priority]

TC002 Case Appears In List View
    [Tags]    TC002
    ${CASE}=    Build Case Data    priority=High
    Set Test Variable    ${CASE}
    Create Case    ${CASE}
    Open Case By Subject    ${CASE}[subject]
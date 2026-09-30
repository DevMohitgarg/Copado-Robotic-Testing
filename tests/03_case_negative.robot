*** Settings ***
Documentation    Negative / validation scenarios.
Resource         ../resources/common.robot
Resource         ../resources/case_keywords.robot
Suite Setup      Setup Browser
Suite Teardown   End Suite
Test Teardown    Capture Debug Info On Failure
Force Tags       case-mgmt    negative

*** Test Cases ***
TC201 Cannot Save Case Without Required Fields
    [Tags]    TC201
    Return To Cases List
    ClickText     New
    UseModal      On
    ClickText     Save    partial_match=False
    VerifyText    Complete this field    timeout=${SHORT}
    ClickText     Cancel
    UseModal      Off
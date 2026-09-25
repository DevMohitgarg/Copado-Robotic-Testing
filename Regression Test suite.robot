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
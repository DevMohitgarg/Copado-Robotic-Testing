# Test asset originally created using Copado QEditor.
#

*** Settings ***
Library                      String
Documentation                New test suite
# You can change imported library to "QWeb" if testing generic web application, not Salesforce.
Library                      QForce
Library                      QWeb
Library                      Collections
# Library                    QMobile
Library                      Collections
Suite Setup                  Open Browser                about:blank                 chrome
Suite Teardown               Close All Browsers

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


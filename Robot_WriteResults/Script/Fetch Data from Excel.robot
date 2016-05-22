*** Settings ***
Suite Setup       Create Result File
Library           ExcelLibrary
Library           OperatingSystem
Library           robot.api.logger
Library           Selenium2Library
Library           String

*** Variables ***
${sFileName}      ${EXECDIR}\\Data\\TestSheet.xls    # DataSheet
${sResultFilePath}    ${EXECDIR}\\Results\\Results    # ResultFile

*** Test Cases ***
TC01_Fetch Data From Excel & Write Results
    [Setup]    Append Test Details to Results File
    Open given Excel file    ${sFileName}
    ${sURL}    Get data from Excel with given column    Data    TC_02    Url
    Log    ${sURL}
    [Teardown]    Publish Test Case Result

*** Keywords ***
Open given Excel file
    [Arguments]    ${sFileName}
    #Check that the given Excel Exists
    ${inputfileStatus}    ${msg}    Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${sFileName}
    Run Keyword If    "${inputfileStatus}"=="PASS"    info    ${sFileName} Test data file exist    ELSE    Fail    Cannot locate the given Excel file.
    Open Excel    ${sFileName}

Get data from Excel with given column
    [Arguments]    ${sSheetName}    ${sTestCaseNo}    ${sColumnName}
    log    ${sColumnName}
    ${colCount}    Get Column Count    ${sSheetName}
    : FOR    ${y}    IN RANGE    0    ${colCount}
    \    ${header}    Read Cell Data By Coordinates    ${sSheetName}    ${y}    0
    \    #Check if this is the given header
    \    Run Keyword If    "${header}"=="${sColumnName}"    Set Test Variable    ${colNum}    ${y}
    log    ${colNum}
    #Get the total rows in the Sheet
    ${iTotalRows}    ExcelLibrary.Get Row Count    ${sSheetName}
    : FOR    ${iRowNo}    IN RANGE    1    ${iTotalRows}+1
    \    ${TC_Num}    Read Cell Data By Coordinates    ${sSheetName}    0    ${iRowNo}
    \    #Incase TestCase No is same , fetch the data from same row and given column No
    \    ${sSearchedData}    Run Keyword If    "${sTestCaseNo}"=="${TC_Num}"    ExcelLibrary.Read Cell Data By Coordinates    ${sSheetName}    ${colNum}
    \    ...    ${iRowNo}
    \    Run Keyword If    "${sTestCaseNo}"=="${TC_Num}"    Exit For Loop
    [Return]    ${sSearchedData}

Create Result File
    [Documentation]    Create a result file at runtime
    ${sResultFile}    Add TimeStamp to File    ${sResultFilePath}
    #Create Result file at the given location
    Create File    ${sResultFile}
    Append to file    ${sResultFile}    TC_Number\tTC_Desc\tStatus\tComments\n
    Set Global Variable    ${sResultFile}    ${sResultFile}

Add TimeStamp to File
    [Arguments]    ${sResultFilePath}
    [Documentation]    Creating the Name of the Results file based on the current TimeStamp
    ${date}    OperatingSystem.Run    echo %date%
    ${yyyy}    ${mm}    ${dd}    Split String    ${date}    /
    ${time}    OperatingSystem.Run    echo %time%
    ${hh}    ${min}    ${sec}    Split String    ${time}    :
    #Creating TimeStamp
    ${timestamp}    Set Variable    ${mm}${dd}${yyyy}_${hh}${min}
    log    ${timestamp}
    ${sfileName}    Set Variable    ${sResultFilePath}_${timestamp}.xls
    [Return]    ${sfileName}

Append Test Details to Results File
    [Documentation]    Adding Test Case Details to Results File
    #Fetch TC No
    ${sTCNo}    ${sTestDesc}    Split String    ${TESTNAME}    _
    append to file    ${sResultFile}    ${sTCNo}\t${sTestDesc}\t

Publish Test Case Result
    [Documentation]    Adding TC fail/pass results to Result File
    append to file    ${sResultFile}    ${TEST STATUS}\t${TEST MESSAGE}\n
    Close All Browsers

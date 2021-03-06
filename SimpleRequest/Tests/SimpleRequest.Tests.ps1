$ModulePath = Split-Path -Path $PSScriptRoot -Parent
$ModuleName = Split-Path -Path $ModulePath -Leaf

# Make sure one or multiple versions of the module are not loaded
Get-Module -Name $ModuleName | Remove-Module
# Import the module and store the information about the module
$ModuleInformation = Import-Module -Name "$ModulePath\$ModuleName.psd1" -PassThru
$ModuleInformation | Format-List

# Get the functions present in the Manifest
$ExportedFunctions = $ModuleInformation.ExportedFunctions.Values.Name

# Get the functions present in the Public folders
$PS1Functions = Get-ChildItem -Path "$ModulePath\Public\*.ps1"

$data = @{
    "Id"           = 99
    "Value"        = "Content"
    "FakeToken"    = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
}

Describe "$ModuleName Module" {
    Context "Manifest" {
        It "Should contain RootModule" {
            $ModuleInformation.RootModule | Should -Not -BeNullOrEmpty
        }

        It "Should contain ModuleVersion" {
            $ModuleInformation.Version | Should -Not -BeNullOrEmpty
        }

        It "Should contain GUID" {
            $ModuleInformation.Guid | Should -Not -BeNullOrEmpty
        }

        It "Should contain Author" {
            $ModuleInformation.Author | Should -Not -BeNullOrEmpty
        }

        It "Should contain Description" {
            $ModuleInformation.Description | Should -Not -BeNullOrEmpty
        }

        It "Compare the count of Function Exported and the PS1 files found" {
            $status = $ExportedFunctions.Count -eq $PS1Functions.Count
            $status | Should -BeTrue
        }

        It "Compare the missing function" {
            If ($ExportedFunctions.count -ne $PS1Functions.count) {
                $Compare = Compare-Object -ReferenceObject $ExportedFunctions -DifferenceObject $PS1Functions.Basename
                $Compare.InputObject -Join ',' | Should -BeNullOrEmpty
            }
        }
    }
    
    Context "Request Method" {
        It "Should send GET request" {
            
            $syntax = "GET https://httpbin.org/get"

            $Response = Invoke-SimpleRequest -Syntax $syntax
            $Response.StatusCode | Should -BeExactly 200
        }

        It "Should send POST request" {
            
            $syntax = "POST https://httpbin.org/post"

            $Response = Invoke-SimpleRequest -Syntax $syntax
            $Response.StatusCode | Should -BeExactly 200
        }

        It "Should send PUT request" {
            
            $syntax = "PUT https://httpbin.org/put"

            $Response = Invoke-SimpleRequest -Syntax $syntax
            $Response.StatusCode | Should -BeExactly 200
        }

        It "Should send PATCH request" {
            
            $syntax = "PATCH https://httpbin.org/patch"

            $Response = Invoke-SimpleRequest -Syntax $syntax
            $Response.StatusCode | Should -BeExactly 200
        }

        It "Should send DELETE request" {
            
            $syntax = "DELETE https://httpbin.org/delete"

            $Response = Invoke-SimpleRequest -Syntax $syntax
            $Response.StatusCode | Should -BeExactly 200
        }
    }

    Context "Request Headers" {
        It "Should send GET headers" {
            
            $syntax = "
            GET https://httpbin.org/anything

            Authorization: AuthToken
            x-custom-header: CustomHeader
            "

            $Response = Invoke-SimpleRequest -Syntax $syntax
            $Response.StatusCode | Should -BeExactly 200
            $Headers = ($Response.Content | ConvertFrom-Json).headers
            $Headers.Authorization | Should -BeExactly "AuthToken"
            $Headers."x-custom-header" | Should -BeExactly "CustomHeader"
        }

        It "Should send POST headers" {
            
            $syntax = "
            POST https://httpbin.org/anything

            Authorization: AuthToken
            x-custom-header: CustomHeader
            "

            $Response = Invoke-SimpleRequest -Syntax $syntax
            $Response.StatusCode | Should -BeExactly 200
            $Headers = ($Response.Content | ConvertFrom-Json).headers
            $Headers.Authorization | Should -BeExactly "AuthToken"
            $Headers."x-custom-header" | Should -BeExactly "CustomHeader"
        }

        It "Should send PUT headers" {
            
            $syntax = "
            PUT https://httpbin.org/anything

            Authorization: AuthToken
            x-custom-header: CustomHeader
            "

            $Response = Invoke-SimpleRequest -Syntax $syntax
            $Response.StatusCode | Should -BeExactly 200
            $Headers = ($Response.Content | ConvertFrom-Json).headers
            $Headers.Authorization | Should -BeExactly "AuthToken"
            $Headers."x-custom-header" | Should -BeExactly "CustomHeader"
        }

        It "Should send PATCH headers" {
            
            $syntax = "
            PATCH https://httpbin.org/anything

            Authorization: AuthToken
            x-custom-header: CustomHeader
            "

            $Response = Invoke-SimpleRequest -Syntax $syntax
            $Response.StatusCode | Should -BeExactly 200
            $Headers = ($Response.Content | ConvertFrom-Json).headers
            $Headers.Authorization | Should -BeExactly "AuthToken"
            $Headers."x-custom-header" | Should -BeExactly "CustomHeader"
        }

        It "Should send DELETE headers" {
            
            $syntax = "
            DELETE https://httpbin.org/anything

            Authorization: AuthToken
            x-custom-header: CustomHeader
            "

            $Response = Invoke-SimpleRequest -Syntax $syntax
            $Response.StatusCode | Should -BeExactly 200
            $Headers = ($Response.Content | ConvertFrom-Json).headers
            $Headers.Authorization | Should -BeExactly "AuthToken"
            $Headers."x-custom-header" | Should -BeExactly "CustomHeader"
        }

    }

    Context "Edge Cases" {

        It "Should send empty headers" {
            $syntax = '
            POST https://httpbin.org/anything
            
            x-empty-header: 
            x-bearer-token: {{FakeToken}}
            x-empty-header2: 

            {
                "id": {{Id}},
                "value": "{{Value}}"
            }
            '

            $Response = Invoke-SimpleRequest -Syntax $syntax -Context $data
            $Response.StatusCode | Should -BeExactly 200
            $Headers = ($Response.Content | ConvertFrom-Json).headers
            $Headers."x-bearer-token" | Should -BeExactly $data.FakeToken
            $Headers."x-empty-header" | Should -BeNullOrEmpty
            $Headers."x-empty-header2" | Should -BeNullOrEmpty
            
        }

        It "Should send last header with same field name" {
            $syntax = '
            POST https://httpbin.org/anything
            
            x-same-header: first
            x-same-header: last 

            {
                "id": {{Id}},
                "value": "{{Value}}"
            }
            '

            $Response = Invoke-SimpleRequest -Syntax $syntax
            $Response.StatusCode | Should -BeExactly 200
            $Headers = ($Response.Content | ConvertFrom-Json).headers
            $Headers."x-same-header" | Should -BeExactly "last"
            
        }
        
    }

    Context "Request Payload" {
        It "Should ignore GET payload" {
            
            $syntax = '
            GET https://httpbin.org/anything

            Authorization: AuthToken
            x-custom-header: CustomHeader
            {
                "id": 1,
                "value": "Value"
            }
            '

            $Response = Invoke-SimpleRequest -Syntax $syntax
            $Response.StatusCode | Should -BeExactly 200
            $Headers = ($Response.Content | ConvertFrom-Json).headers
            $Headers.Authorization | Should -BeExactly "AuthToken"
            $Headers."x-custom-header" | Should -BeExactly "CustomHeader"
            $Content = $Response.Content | ConvertFrom-Json
            $Content.json | Should -BeNullOrEmpty
        }

        It "Should send POST payload" {
            
            $syntax = '
            POST https://httpbin.org/anything

            Authorization: AuthToken
            x-custom-header: CustomHeader
            
            {
                "id": 1,
                "value": "Value"
            }
            '

            $Response = Invoke-SimpleRequest -Syntax $syntax
            $Response.StatusCode | Should -BeExactly 200
            $Headers = ($Response.Content | ConvertFrom-Json).headers
            $Headers.Authorization | Should -BeExactly "AuthToken"
            $Headers."x-custom-header" | Should -BeExactly "CustomHeader"
            $Content = $Response.Content | ConvertFrom-Json
            $Content.json.id | Should -BeExactly 1
            $Content.json.value | Should -BeExactly "Value"
        }

        It "Should send PUT payload" {
            
            $syntax = '
            PUT https://httpbin.org/anything

            Authorization: AuthToken
            x-custom-header: CustomHeader
            {
                "id": 1,
                "value": "Value"
            }
            '

            $Response = Invoke-SimpleRequest -Syntax $syntax
            $Response.StatusCode | Should -BeExactly 200
            $Headers = ($Response.Content | ConvertFrom-Json).headers
            $Headers.Authorization | Should -BeExactly "AuthToken"
            $Headers."x-custom-header" | Should -BeExactly "CustomHeader"
            $Content = $Response.Content | ConvertFrom-Json
            $Content.json.id | Should -BeExactly 1
            $Content.json.value | Should -BeExactly "Value"
        }

        It "Should send PATCH payload" {
            
            $syntax = '
            PATCH https://httpbin.org/anything

            Authorization: AuthToken
            x-custom-header: CustomHeader
            {
                "id": 1,
                "value": "Value"
            }
            '

            $Response = Invoke-SimpleRequest -Syntax $syntax
            $Response.StatusCode | Should -BeExactly 200
            $Headers = ($Response.Content | ConvertFrom-Json).headers
            $Headers.Authorization | Should -BeExactly "AuthToken"
            $Headers."x-custom-header" | Should -BeExactly "CustomHeader"
            $Content = $Response.Content | ConvertFrom-Json
            $Content.json.id | Should -BeExactly 1
            $Content.json.value | Should -BeExactly "Value"
        }

        It "Should send DELETE payload" {
            
            $syntax = '
            DELETE https://httpbin.org/anything

            Authorization: AuthToken
            x-custom-header: CustomHeader
            {
                "id": 1,
                "value": "Value"
            }
            '

            $Response = Invoke-SimpleRequest -Syntax $syntax
            $Response.StatusCode | Should -BeExactly 200
            $Headers = ($Response.Content | ConvertFrom-Json).headers
            $Headers.Authorization | Should -BeExactly "AuthToken"
            $Headers."x-custom-header" | Should -BeExactly "CustomHeader"
            $Content = $Response.Content | ConvertFrom-Json
            $Content.json.id | Should -BeExactly 1
            $Content.json.value | Should -BeExactly "Value"
        }
    }

    Context "Request variable" {
        It "Should GET support variable" {
            
            $syntax = '
            GET https://httpbin.org/anything?id={{Id}}

            Authorization: AuthToken
            x-custom-header: {{Value}}

            {
                "id": {{Id}},
                "value": "{{Value}}"
            }
            '

            $Response = Invoke-SimpleRequest -Syntax $syntax -Context $data
            $Response.StatusCode | Should -BeExactly 200
            $args = ($Response.Content | ConvertFrom-Json).args
            $args.id | Should -BeExactly $data.Id
            $Headers = ($Response.Content | ConvertFrom-Json).headers
            $Headers.Authorization | Should -BeExactly "AuthToken"
            $Headers."x-custom-header" | Should -BeExactly $data.Value
            $Content = $Response.Content | ConvertFrom-Json
            $Content.json | Should -BeNullOrEmpty
        }

        It "Should POST support variable" {

            $syntax = '
            POST https://httpbin.org/anything?id={{Id}}

            Authorization: AuthToken
            x-custom-header: {{Value}}

            {
                "id": {{Id}},
                "value": "{{Value}}"
            }
            '

            $Response = Invoke-SimpleRequest -Syntax $syntax -Context $data
            $Response.StatusCode | Should -BeExactly 200
            $args = ($Response.Content | ConvertFrom-Json).args
            $args.id | Should -BeExactly $data.Id
            $Headers = ($Response.Content | ConvertFrom-Json).headers
            $Headers.Authorization | Should -BeExactly "AuthToken"
            $Headers."x-custom-header" | Should -BeExactly $data.Value
            $Content = $Response.Content | ConvertFrom-Json
            $Content.json.id | Should -BeExactly $data.Id
            $Content.json.value | Should -BeExactly $data.Value
        }

        It "Should PUT support variable" {

            $syntax = '
            PUT https://httpbin.org/anything?id={{Id}}

            Authorization: AuthToken
            x-custom-header: {{Value}}

            {
                "id": {{Id}},
                "value": "{{Value}}"
            }
            '

            $Response = Invoke-SimpleRequest -Syntax $syntax -Context $data
            $Response.StatusCode | Should -BeExactly 200
            $args = ($Response.Content | ConvertFrom-Json).args
            $args.id | Should -BeExactly $data.Id
            $Headers = ($Response.Content | ConvertFrom-Json).headers
            $Headers.Authorization | Should -BeExactly "AuthToken"
            $Headers."x-custom-header" | Should -BeExactly $data.Value
            $Content = $Response.Content | ConvertFrom-Json
            $Content.json.id | Should -BeExactly $data.Id
            $Content.json.value | Should -BeExactly $data.Value
        }

        It "Should PATCH support variable" {

            $syntax = '
            PATCH https://httpbin.org/anything?id={{Id}}

            Authorization: AuthToken
            x-custom-header: {{Value}}

            {
                "id": {{Id}},
                "value": "{{Value}}"
            }
            '

            $Response = Invoke-SimpleRequest -Syntax $syntax -Context $data
            $Response.StatusCode | Should -BeExactly 200
            $args = ($Response.Content | ConvertFrom-Json).args
            $args.id | Should -BeExactly $data.Id
            $Headers = ($Response.Content | ConvertFrom-Json).headers
            $Headers.Authorization | Should -BeExactly "AuthToken"
            $Headers."x-custom-header" | Should -BeExactly $data.Value
            $Content = $Response.Content | ConvertFrom-Json
            $Content.json.id | Should -BeExactly $data.Id
            $Content.json.value | Should -BeExactly $data.Value
        }

        It "Should DELETE support variable" {

            $syntax = '
            DELETE https://httpbin.org/anything?id={{Id}}

            Authorization: AuthToken
            x-custom-header: {{Value}}

            {
                "id": {{Id}},
                "value": "{{Value}}"
            }
            '

            $Response = Invoke-SimpleRequest -Syntax $syntax -Context $data
            $Response.StatusCode | Should -BeExactly 200
            $args = ($Response.Content | ConvertFrom-Json).args
            $args.id | Should -BeExactly $data.Id
            $Headers = ($Response.Content | ConvertFrom-Json).headers
            $Headers.Authorization | Should -BeExactly "AuthToken"
            $Headers."x-custom-header" | Should -BeExactly $data.Value
            $Content = $Response.Content | ConvertFrom-Json
            $Content.json.id | Should -BeExactly $data.Id
            $Content.json.value | Should -BeExactly $data.Value
        }
    }

    Context "Multiline Requests" {
        It "Should compose several requests in a single syntax" {

            $syntax = '
            GET https://httpbin.org/get

            x-custom-header: CustomHeader
            Authorization: AuthToken

            ###

            POST https://httpbin.org/anything

            Content-Type: application/json

            {
                "id": 1
            }
            '

            $Response = Invoke-SimpleRequest -Syntax $syntax
            $Response.Count | Should -BeExactly 2

            $Response1 = $Response[0]
            $Response1.StatusCode | Should -BeExactly 200
            $Headers = ($Response1.Content | ConvertFrom-Json).headers
            $Headers.Authorization | Should -BeExactly "AuthToken"
            $Headers."x-custom-header" | Should -BeExactly "CustomHeader"

            $Response2 = $Response[1]
            $Response2.StatusCode | Should -BeExactly 200
            $Content = $Response2.Content | ConvertFrom-Json
            $Content.json.id | Should -BeExactly 1
        }
    }

    Context "Input from file" {
        It "Should send request defined in file" {
            $Response = Invoke-SimpleRequest -Path "$($PSScriptRoot)\..\..\TestData\sample.sr"
            $Response.StatusCode | Should -BeExactly 200
            $Headers = ($Response.Content | ConvertFrom-Json).headers
            $Headers.Authorization | Should -BeExactly "AuthToken"
            $Headers."x-custom-header" | Should -BeExactly "CustomHeader"
            $Content = $Response.Content | ConvertFrom-Json
            $Content.json.id | Should -BeExactly 1
            $Content.json.value | Should -BeExactly "Value"
        }
    }
    
}

Get-Module -Name $ModuleName | Remove-Module
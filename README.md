SimpleRequest
=============
SimpleRequest is inspired by the HTTP Client in WebStrom, allow you to

- Compose an HTTP request by using general syntax
- Use variables to parametrize elements
- Intergate with Pester

![CI](https://github.com/toolkitx/simple-request/workflows/CI/badge.svg?branch=master)

## Installation

Running this PowerShell command

```ps
Install-Module -Name SimpleRequest	
```


## Syntax

```
METHOD Request-URI
Header-field: Header-value

Request-Body
```

Compose HTTP request as bellow:
```ps
Invoke-SimpleRequest -Syntax $Syntax [-Context $ContextData]
```

### Get Request Syntax
```
GET https://httpbin.org/ip
Content-Type: application/json 
```

### POST Request Syntax
```
POST https://httpbin.org/post

Content-Type: application/json

{
    "id": 1,
    "value": "the-value"
}
```


## Use Variables

When composing an HTTP request, you can parametrize its elements by using variables. To provide the variable inside the request, enclose it in double curly braces as `{{variable}}`. 

```PS
$Data = @{
    "TokenUrl"     = 111
    "ClientSecret" = "222"
    "ClientId"     = "333"
    "AuthResource" = "444"
    "Username"     = "User1"
    "Password"     = "Password"
    "Id"           = 99
    "Price"        = 0.99
    "Value"        = "Content"
}

$Sample = '
POST https://httpbin.org/post?id={{Id}}

Content-Type: application/json
Authorization: Bearer {{QIBToken}}

{
    "id": {{Id}},
    "value": "{{Value}}"
}'

$Response = Invoke-SimpleRequest -Syntax $Sample -Context $Data
```

### Compose several requests in a single syntax
Compose several requests in a single syntax, separate by `###`
```
GET https://httpbin.org/ip

### 

GET https://httpbin.org/anything
```

### Compose requests from single file

For example, you have a `sample.sr` contains below syntax:

```json
POST https://httpbin.org/anything

Authorization: AuthToken
x-custom-header: CustomHeader

{
    "id": 1,
    "value": "Value"
}
```
Then you can invoke it like this

```
Invoke-SimpleRequest -Path .\sample.sr
```

### TODO

- [x] Support compose requests from single file
- [x] Support empty header field value
- [x] Support headers with same field name, only the last one will be sent, values should be defined as a comma-separated list
- [ ] Predefined dynamic variables
- [x] Compose several requests in a single syntax, separate by `###`
- [ ] Break long requests into several lines
- [ ] Support multipart/form-data content type
- [ ] Export response to file

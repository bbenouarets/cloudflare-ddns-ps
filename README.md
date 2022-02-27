# cloudflare-ddns-ps

## Usage
Navigate to the directory where the downloaded scripts are.

```ps1
Import-Module .\Update-DNS.ps1
Update-DNSRecord -Email <:Email> -Token <:Token> -ZoneID <:ZoneID> -DNSRecord <:DNSRecord> -Notification <:Notification> -NotificationURL <:NotificationURL> -NotificationImage <:NotificationImage>
```

| Parameter          | Required                | Function              |
|:-------------------|:------------------------|:----------------------|
| Email              | :white_check_mark:      | Cloudflare Email      |
| Token              | :white_check_mark:      | Cloudflare API Token  |
| Zone ID            | :white_check_mark:      | Zone ID of Domain     |
| DNS Record         | :white_check_mark:      | DNS Record of Domain  |
| Notification       | :white_check_mark:      | Notification Provider |
| Notification URL   | :white_check_mark:      | URL of Webhook        |
| Notification Image | :white_check_mark:      | URL of Image          |


## Notification
| Provider        | Name       |
|:----------------|:-----------|
| Microsoft Teams | Teams      |
| Webhooks        | Webhook    |

## Powershell: Execution Policy
Execute the following Powershell command in as admin:
```ps1
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
```
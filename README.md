## Ciscobar ![enter image description here](https://img.shields.io/static/v1?label=release&message=1.0&color=silver)
Ciscobar is a user-friendly and efficient tool designed to streamline the process of searching for Cisco contacts by name or phone number.
### Features
 - Effortless Search: quickly and easily find contact information without any hassle or extra effort.
 - Swift Call: effortlessly initiate, and end a telephone call with the mere tap of a button. ![enter image description here](https://img.shields.io/badge/soon-silver)
 - Easy Access: simplified Connection to Cisco Unified Communications Manager services at the click of a button.
 - Secured Data: your data is protected using logon credentials, ensuring that only you can access it.
### Supported platforms
![enter image description here](https://img.shields.io/static/v1?label=Windows&message=available&color=silver&style=for-the-badge&logo=windows&logoColor=white)
![enter image description here](https://img.shields.io/static/v1?label=Mac%20OS&message=soon&color=silver&style=for-the-badge&logo=apple&logoColor=white)
![enter image description here](https://img.shields.io/static/v1?label=Linux&message=soon&color=silver&style=for-the-badge&logo=linux&logoColor=white)
### Supported languages
- English
- Spanish
- French
> Explore the src/locales directory to contribute to translations in your language or help correct any typos!
### Get started
To begin using Ciscobar, you need to provide three essential parameters either through the user interface or the command line
#### Via User Interface:

![ciscobar](https://github.com/abdelbenbaha/ciscobar/assets/45561892/e8213100-062b-469e-b123-e05bc784ff23)

1.  **CUCM Base URL:** The base URL for connecting to the Cisco Unified Communications Manager (CUCM) should be provided in the following format: `https://{cucm_hostname}`.
    
2.  **Username:** You need to enter a valid username to authenticate with CUCM and access its resources.
    
3.  **Password:** The corresponding password for the provided username is required for secure authentication.

#### Via Command Line:

Alternatively, you can also use the command line to set up Ciscobar with the following syntax:

    ciscobar -s:{cucm_hostname} -u:{username} -p:{password}


 > For detailed instructions on creating a dedicated AXL (Administrative XML) user, please refer to the [authentication guide](https://developer.cisco.com/docs/axl/#!authentication).

### Credit

 - [skia4delphi](https://github.com/skia4delphi)
 - [neslib.xml](https://github.com/neslib/Neslib.Xml)
 - [SVGIconImageList](https://github.com/EtheaDev/SVGIconImageList)
 - [Inno Setup](https://jrsoftware.org/isinfo.php)


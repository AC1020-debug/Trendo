const amplifyconfig = '''{
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "UserAgent": "aws-amplify-flutter/1.0.0",
        "Version": "1.0",
        "IdentityManager": {
          "Default": {}
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "ap-southeast-1_xfNxpd8bW",
            "AppClientId": "7ud7dil1eqslmhequvqjgu12h2",
            "Region": "ap-southeast-1"
          }
        },
        "Auth": {
          "Default": {
            "authenticationFlowType": "USER_SRP_AUTH",
            "usernameAttributes": ["email"],
            "signupAttributes": ["email"],
            "passwordProtectionSettings": {
              "passwordPolicyMinLength": 8,
              "passwordPolicyCharacters": []
            },
            "mfaConfiguration": "OFF",
            "mfaTypes": ["SMS"],
            "verificationMechanisms": ["EMAIL"]
          }
        }
      }
    }
  }
}''';
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
        "CognitoIdentityPool": {
          "Default": {
            "PoolId": "ap-southeast-1:029c352c-812b-44e2-9894-6a40ee41a16d",
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
  },
  "storage": {
    "plugins": {
      "awsS3StoragePlugin": {
        "bucket": "trendo-retailer-csv",
        "region": "ap-southeast-1",
        "defaultAccessLevel": "guest"
      }
    }
  }
}''';
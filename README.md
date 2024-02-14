# This code is for below security requirement

1. You have a number of Windows clients which already joined enterprise AD.
2. based on security base line, most of your users have no local administrator right.
3. management on local administrator password is a huge workload for the ICT people.
   
   how to do management password based on ISO27002:
   
        1. administrator password shall be regular changed.

        2. aline with password policy.


# Tools we used

    hashicorp/vault Community
    
    https://github.com/hashicorp/vault
    
    https://developer.hashicorp.com/vault/install?product_intent=vault


# Vault configuration

## 1. Common config.hcl

ui = true

disable_mlock = true

storage "raft" {

  path    = "./vault/data"
  
  node_id = "node1"

}


listener "tcp" {

  address     = "0.0.0.0:8200"
  
  tls_disable = "true"

}


api_addr = "http://127.0.0.1:8200"

cluster_addr = "https://127.0.0.1:8201"

## 2. Secrets engines

   2 KV Secrets engines, one is version2 , the other is version 1.

   like below
   
<img width="332" alt="image" src="https://github.com/parrotao/Vault_Windows_Admins_Password_Change/assets/37337484/6a79f0f6-4a72-4fd2-a23d-a803e5d0be7e">

## 3. Create user for each client

## 4. Create new policy for the user

<<PolicyName = win_pass>>

path "kv/*" {

capabilities = ["create", "read", "update", "delete", "list"]

}

path "kv_v1/*" {

capabilities = [ "update"]

}

path "sys/capabilities-self" { 

    capabilities = ["create", "read", "update", "delete", "list"]

}

path "sys/mounts/*"

{

capabilities = [ "read"]

}

path "sys/mounts" {

capabilities = [ "read"]

}

## 5. Assign policy to user

vault write auth/userpass/users/<%user_name%>  policies=win_pass

and Do Not Attach 'default' Policy To Generated Tokens

<img width="699" alt="image" src="https://github.com/parrotao/Vault_Windows_Admins_Password_Change/assets/37337484/db35aec0-fb9e-4cad-addd-5156140fd947">


## 6. Run Sourcecode with the account have local adminstrator right
##

# This library is a simple way to do encryption for storage into a database. 
# The user will create a public and private key, preferrably with a password 
# before initial use and then call the library to encrypt the data. The libary
# will return the encrypted data, encrypted key and encrypted iv for storage 
# and retrieval at a later date. The only thing needed to unencrypt the data 
# is the password to the OpenSSL private key

# Taken from inspiration from:
# http://stuff-things.net/2008/02/05/encrypting-lots-of-sensitive-data-with-ruby-on-rails/


require 'openssl'
class Rencrypt 

   attr_accessor :plain_data, :encrypted_data , :encrypted_key, :encrypted_iv  
   
   # Decrypt the previously encrypted data
   # * privkey is the pathname to the private openssl key. Make sure its readable by your user
   # * encrypted_data is the actual data to be unencrypted
   # * encrypted_key is the key used on the previously
   # * encrypted_iv is the initialization vector previously used previously
   # * password is the private key password used when the OpenSSL private key was created
   #
   def self.decrypt_sensitive(privkey, encrypted_data, encrypted_key, encrypted_iv, password)  
     if encrypted_data  
       begin
         private_key = OpenSSL::PKey::RSA.new(File.read(privkey),password)  
       rescue Exception => e
         return "There was a problem with the private key: #{e}"
       end
       cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')  
       cipher.decrypt  
       begin   
         cipher.key = private_key.private_decrypt(encrypted_key)  
         cipher.iv = private_key.private_decrypt(encrypted_iv)  
       rescue Exception => e
         return "There was a problem with the key or IV: #{e}"
       end
       decrypted_data = cipher.update(encrypted_data)  
       decrypted_data << cipher.final 
       return decrypted_data 
     else  
       return "Error! No data to decrypt"
     end  
   end  
   
   # Holdover from from the conversion from a Model. Might not be needed. Yet to be seen.
   def self.clear_sensitive  
     self.encrypted_data = self.encrypted_key = self.encrypted_iv = nil  
   end  
   
   # Encrypt data using a previously created public key
   # * The fuction will create a random key and random iv 
   # * Returns the data, key and IV used to encrypt the data
   # * Data, key and IV should be stored for retrieval later
   def self.encrypt_sensitive(pubkey, data)  
     if data
       begin
         public_key = OpenSSL::PKey::RSA.new(File.read(pubkey))  
       rescue Exception => e
         return "There was a problem with the public key: #{e}"
       end
       
       cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')  
       cipher.encrypt  
       cipher.key = random_key = cipher.random_key  
       cipher.iv = random_iv = cipher.random_iv  
    
       encrypted_data = cipher.update(data)  
       encrypted_data << cipher.final  
   
       encrypted_key =  public_key.public_encrypt(random_key)  
       encrypted_iv = public_key.public_encrypt(random_iv)  
     
       return edata = [encrypted_data, encrypted_key, encrypted_iv]
     else 
       return "No data to encrypt"
     end  
   end
end

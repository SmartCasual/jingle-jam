class AddEncryptionToKey < ActiveRecord::Migration[6.1]
  def change
    remove_column :keys, :code, :string, null: false

    # Ciphertext
    add_column :keys, :code_ciphertext, :text

    # Encryption key
    add_column :keys, :encrypted_kms_key, :text

    # Blind index
    add_column :keys, :code_bidx, :string
    add_index :keys, :code_bidx, unique: true
  end
end

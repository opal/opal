opal_filter 'tainted' do
  fails "Array#clear keeps tainted status"
  fails "Array#compact! keeps tainted status even if all elements are removed"
  fails "Array#delete_at keeps tainted status"
  fails "Array#delete_if keeps tainted status"
  fails "Array#delete keeps tainted status"
end

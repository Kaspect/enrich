import hashlib
##################################
#Testing Framework
##################################

def id_number(your_string):
  encoded_str = your_string.encode('utf-8')
  my_id = int(hashlib.md5(encoded_str).hexdigest(), 16)
  return(my_id)

##################################
#Testing Framework
##################################


import unittest
 
class TestUM(unittest.TestCase):
 
	def setUp(self):
		pass

	def test_hex_hash_examples(self):
		self.assertEqual(id_number("test_img_files/IMG_1305.jpg"), 279558192375589665600342317696327885246)

if __name__ == '__main__':
	unittest.main()
	print('Unit tests complete')
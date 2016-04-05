import hashlib
##################################
#Testing Framework
##################################

def id_number(your_string):
  encoded_str = your_string.encode('utf-8')
  my_id = int(hashlib.md5(encoded_str).hexdigest(), 16)
  return(my_id)

def compose_doi(your_id_number, prefix="10.1234", final_suffix="-polar-enrich"):
  return(prefix + "/" + your_id_number + final_suffix)

def filename_to_doi(filename_string):
  return(compose_doi(str(id_number(filename_string))))

###Project-specific hashing functionality###

def load_filename_list_txt(filename_string):
  text_file = open(filename_string, "r")
  lines = text_file.read().split('\n')
  return(lines)

def filename_list_to_list_of_DOIs(filename_list):
  return([filename_to_doi(filename) for filename in filename_list])


def output_doi_txt(filename_string, output_filename):
  """
  @param filename_string The path to a filename list, where each line is a unique string. Must all be unique strings.
  """
  output_DOI_list = filename_list_to_list_of_DOIs(load_filename_list_txt(filename_string))
  data = open(output_filename, "w")
  for DOI_string in output_DOI_list:
    data.write("%s\n" % DOI_string)


##################################
#Testing Framework
##################################


import unittest
 
class TestUM(unittest.TestCase):
 
  def setUp(self):
    pass

  def test_hex_hash_examples(self):
    self.assertEqual(id_number("test_img_files/IMG_1305.jpg"), 279558192375589665600342317696327885246)
    
  def test_enrichment_doi(self):
    self.assertEqual(filename_to_doi("test_img_files/IMG_1305.jpg"),"10.1234/279558192375589665600342317696327885246-polar-enrich")




if __name__ == '__main__':
  unittest.main()
  print('Unit tests complete')

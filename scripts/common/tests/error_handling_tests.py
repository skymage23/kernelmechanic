#!/usr/bin/env python3
import pathlib
import sys
import unittest

sys.path.append(pathlib.Path.cwd().parent.__str__())
import error_handling

class ErrcodeHandlerTest(unittest.TestCase):
    #Hello

    def setUp(self):
        self.errcode_handler = error_handling.ErrcodeHandler()
        self.mod_name = "test_mod"

    def tearDown(self):
        self.errcode_handler = None

    def test_rng_can_generate(self):
        module = error_handling.ErrcodeModule()
        module.errcodes[1] = error_handling.Errcode("Test1", "Test is 1", 1)
        module.errcodes[2] = error_handling.Errcode("Test2", "Test is 2", 2)


        num = error_handling.ErrcodeHandler.generateErrcode(module)
        self.assertTrue(num <= error_handling.ErrcodeHandler.RNG_MAX_INT_VALUE)
        self.assertTrue(num >= error_handling.ErrcodeHandler.RNG_MIN_INT_VALUE)

    def test_errcode_add_with_num(self):
        errcode = None
        module = None
        name = "Test1"
        message = "This is Test 1"
        number = 1

        retval = self.errcode_handler.registerErrcode(
            mod_name = self.mod_name,
            name = name,
            message = message,
            number = number
        )

        self.assertEqual(retval, number)

        module = self.errcode_handler.modules.get(self.mod_name)
        self.assertTrue(module is not None)
        retval = module.errcodes_key_name.get(name)
        self.assertTrue(retval is not None)
        self.assertEqual(retval, number)

        retval = module.errcodes.get(number)
        self.assertTrue(retval is not None)

        self.assertEqual(retval.name, name)
        self.assertEqual(retval.number, number)
        self.assertEqual(retval.message, message)

    def test_errcode_add_without_num(self):
        #Hello
        name = "Test1"
        message = "This is Test 1"
        number = None
        module = None
        retval = None

        number = self.errcode_handler.registerErrcode(
                    mod_name = self.mod_name,
                    name = name,
                    message = message
                )

        self.assertTrue(number <= error_handling.ErrcodeHandler.RNG_MAX_INT_VALUE)
        self.assertTrue(number >= error_handling.ErrcodeHandler.RNG_MIN_INT_VALUE)

        module = self.errcode_handler.modules.get(self.mod_name)
        self.assertTrue(module is not None)
        retval = module.errcodes_key_name.get(name)
        self.assertTrue(retval is not None)
        self.assertEqual(retval, number)

        retval = module.errcodes.get(number)
        self.assertTrue(retval is not None)

        self.assertEqual(retval.name, name)
        self.assertEqual(retval.number, number)
        self.assertEqual(retval.message, message)

    
    def test_register_mod_name_none(self):
        self.assertRaises(ValueError, 
                              self.errcode_handler.registerErrcode,
                              None,
                              "Test1",
                              "This is Test 1",
                              1
                          )


    def test_register_name_none(self):
        self.assertRaises(ValueError,
                              self.errcode_handler.registerErrcode,
                              self.mod_name,
                              None,
                              "This is Test 1",
                              1
                          )

    def test_register_message_none(self):
        self.assertRaises(ValueError,
                              self.errcode_handler.registerErrcode,
                              self.mod_name,
                              "Test1",
                              None,
                              1
                         )



if __name__ == "__main__":
    unittest.main()



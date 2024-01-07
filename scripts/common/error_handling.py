import numbers
import random

class ErrcodeHandlerError(Exception):
    def __init__(self, message = None):
        if message is None:
            raise ValueError("message cannot be None")

        super().__init__(message)


class Errcode:
    def __init__(self, name = None, message = None, number = None):
        if name is None:
            raise ValueError("name cannot be None.")
        
        if message is None:
            raise ValueError("message cannot be None.")
        
        if number is None:
            raise ValueError("number cannot be None.")

        self.name = name
        self.message = message
        self.number = number

class ErrcodeModule:
    def __init__(self):
        self.errcodes = {}
        self.errcodes_key_name = {}


class ErrcodeHandler:

    RNG_MAX_INT_VALUE=18446744073709551615 #(2^64) - 1; Arbitrarily chosen.
    RNG_MIN_INT_VALUE=0 
    RNG_LOOP_COUNT_LIMIT=10

    instance = None

    @staticmethod
    def generateErrcode(module = None):
        if module is None:
            raise ValueError("module cannot be None.")

        random.seed() #Needed in order to get any entropy for RNG.
        candidate = None
        retval = None
        count = 0
        unique_found = False
        keys = module.errcodes.keys()
        while (not unique_found and (
            count < ErrcodeHandler.RNG_LOOP_COUNT_LIMIT)
        ):
            candidate = random.randint(ErrcodeHandler.RNG_MIN_INT_VALUE,
                                       ErrcodeHandler.RNG_MAX_INT_VALUE)
            if candidate not in keys:
                retval = candidate
                unique_found = True
                break
            count = count + 1

        if (count >= ErrcodeHandler.RNG_LOOP_COUNT_LIMIT):
            raise ErrcodeHandleError("Unable to generate an unused, random errcode value in a reasonable amount of time. You may want to read your OS documentation to see if you can increase the amount of entropy in your system.")

        return retval


    def __init__(self):
        self.modules = {}

    #We return the errcode for two reasons:
    #1.) It may be a generated value.
    #2.) It lets the module author dictate how errcode information
    #    is indexed for their module.
    def registerErrcode(self, mod_name=None, name=None, message=None, number=None):
        if mod_name is None:
            raise ValueError("mod_name cannot be None.")

        if name is None:
            raise ValueError("name cannot be None.")
        
        if message is None:
            raise ValueError("message cannot be None.")

        module = self.modules.get(mod_name)

        if module is None:
            module = ErrcodeModule()
            self.modules[mod_name] = module

        if name in module.errcodes_key_name:
            raise ValueError("An errcode with this name has already been registered.")
         
        if number is None:
            number = ErrcodeHandler.generateErrcode(module)

        module.errcodes_key_name[name] = number
        module.errcodes[number] = Errcode(name,message,number)

        return number

    def getMessage(self, mod_name=None, errcode_input = None):

        if mod_name is None:
            raise ValueError("mod_name cannot be None")

        if errcode_input is None:
            raise ValueError("errcode_input cannot be None.")
        
        index = -1;
        module = self.modules.get(mod_name)
        retval = None

        if module is None:
            raise ErrcodeHandleError("mod_name is not associated with a registered module.")

        if isinstance(errcode_input, str):
            if not errcode_input in module.errcodes_key_name:
                raise ValueError("errcode_input is not registered with any errcode.")

            index = module.errcodes_key_name[name]

        elif isinstance(errcode_input, numbers.Number):
            index = errcode_input
        else:
            raise ValueError("errcode is neither a valid name nor is it a number.")

        return module.errcodes[index].message

ErrcodeHandler.instance = ErrcodeHandler()

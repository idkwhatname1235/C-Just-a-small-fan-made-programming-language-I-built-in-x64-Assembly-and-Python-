
variables = {}


def run(code):
    code = code.strip()

    if not code:
        return

   
    if not code.endswith(";"):
        print("C##++ Error: missing semicolon ';'")
        return

    
    code = code[:-1].strip()

    if code.startswith("mocal "):
        # 'mocal ' vom Anfang abschneiden
        declaration = code[6:].strip()

        if "=" in declaration:
            var_name, var_value = declaration.split("=", 1)
            var_name = var_name.strip()
            var_value = var_value.strip()

    
            if " " in var_name or not var_name:
                print(f"C##++ Error: invalid variable name '{var_name}'")
                return


            if (var_value.startswith('"') and var_value.endswith('"')) or (
                var_value.startswith("'") and var_value.endswith("'")
            ):
                variables[var_name] = var_value[1:-1]
            elif var_value.isdigit():
                variables[var_name] = int(var_value)
            else:

                if var_value in variables:
                    variables[var_name] = variables[var_value]
                else:
                    print(
                        f"C##++ Error: unknown value or variable '{var_value}'"
                    )
                    return
            return


    if code.startswith("print(") and code.endswith(")"):
        value = code[6:-1].strip()


        if (value.startswith('"') and value.endswith('"')) or (
            value.startswith("'") and value.endswith("'")
        ):
            print(value[1:-1])
            return


        if value in variables:
            print(variables[value])
            return

        # Fall C: Zahl wird direkt ausgegeben
        if value.isdigit():
            print(value)
            return

        print(f"C##++ Error: undefined variable or value '{value}'")
        return

    print("C##++ Error: unknown command")


print("Willkommen zu C##++ v0.3!")
while True:
    code = input("C##++ > ")

    if code == "exit":
        break

    run(code)
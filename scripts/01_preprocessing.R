# Import the ursgal library for running the ThermoRawFileParser and other utilities
import ursgal
# Import the os library for file and directory path manipulations
import os
# Import the sys library to work with command-line arguments
import sys
# Import the glob library to perform pattern matching on filenames
import glob


def main(input_path=None):
    """
    Convert a .raw file to .mzML using the ThermoRawFileParser.
    The given argument can be either a single file or a folder
    containing raw files.

    Usage:
        ./convert_raw_to_mzml.py <raw_file/raw_file_folder>
    """
    # Initialize the UController from the ursgal library, which provides access to various engines and utilities
    R = ursgal.UController()

    # Prepare a list to store input .raw file paths
    input_file_list = []

    # Check if the input path is a single .raw file
    if input_path.lower().endswith(".raw"):
        # If it is, add it directly to the input file list
        input_file_list.append(input_path)
    else:
        # If the input is a folder, find all .raw files within the folder
        for raw in glob.glob(os.path.join("{0}".format(input_path), "*.raw")):
            # Add each found .raw file to the input file list
            input_file_list.append(raw)

    # Loop through each .raw file in the collected list
    for raw_file in input_file_list:
        # Convert the .raw file to .mzML format using ThermoRawFileParser
        mzml_file = R.convert(
            input_file=raw_file,  # Specify the .raw file to convert
            engine="thermo_raw_file_parser_1_1_2",  # Specify the conversion engine to use
        )


# Check if the script is being run directly, not imported as a module
if __name__ == "__main__":
    # If the number of arguments passed to the script is not 2 (script name + input path)
    if len(sys.argv) != 2:
        # Print the function's docstring, which contains usage instructions
        print(main.__doc__)
    # Call the main function with the input path provided as the second argument
    main(input_path=sys.argv[1])

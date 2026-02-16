// from base64.cc - c++ source to a base64 reference encoder and decoder

//
// KIM-API: An API for interatomic models
// Copyright (c) 2013--2022, Regents of the University of Minnesota.
// All rights reserved.
//
// Contributors:
//    Navneeth Mohan
//    Amit Gupta
//
// SPDX-License-Identifier: LGPL-2.1-or-later
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation,
// Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
//

//
// Release: This file is part of the kim-api.git repository.
//


#include "KIM_Version.hpp"

#include <b64/encode.h>

#include <fstream>
#include <iostream>
#include <string>

#include <algorithm>
#include <cstdlib>
#include <sstream>

#include <b64/decode.h>


// Function which prints the usage of this executable
void usage(std::string name)
{
  size_t beg = name.find_last_of("/\\");
  if (beg != std::string::npos) name = name.substr(beg + 1, std::string::npos);
  // Follows docopt.org format
  std::cerr << "Usage:\n"
            << "  " << name << " -i <file-in> <file-out>\n"
            << "  " << name << " --version\n";
  // note: this interface is likely to change in future kim-api releases
}

void usage(std::string name, std::string message)
{
  std::cerr << message << std::endl;
  usage(name);
}

// quick replacement of to_string for C++98
inline std::string int_to_string(int value)
{
  std::ostringstream oss;
  oss << value;
  return oss.str();
}

// A C++ implementation of the CMAKE string-operation MAKE_C_IDENTIFIER
std::string make_c_identifier(const std::string & input)
{
  std::string output;

  // If the first character is a digit, prepend an underscore
  if (!input.empty() && std::isdigit(input[0])) output += '_';

  // Process each character
  for (int i = 0; i < input.size(); i++)
  {
    const signed char ch = input[i];
    if (std::isalnum(ch) || ch == '_')
      output += ch;  // Keep letters, numbers, and underscores
    else
      output += '_';  // Replace other characters with underscore
  }

  return output;
}

#include <vector>
void decodeBase64FileInMemory(const std::string& inputfilename)
{
    std::cout << "opening encoded file " << inputfilename << std::endl;
    std::ifstream file(inputfilename.c_str(), std::ios::in | std::ios::binary);
    if (!file) throw std::runtime_error("Failed to open file");

    // get file size
    file.seekg(0, std::ios::end);
    std::streamsize fileLength = file.tellg();
    file.seekg(0, std::ios::beg);

    if (fileLength <= 0) 
    {
        std::cout << "FILELENGTH < 0\n";
        return;
    }

    std::vector<char> buffer((size_t)fileLength);
    file.read(&buffer[0], fileLength);
    if (!file) throw std::runtime_error("Failed to read file");

    std::string content(buffer.begin(), buffer.end());

    // extract the quoted part of the file assuming constant header and footer 
    const std::string header = "extern unsigned char input_txt[] =";
    const std::string footer = "extern unsigned int input_txt_len";
    size_t start = content.find(header);
    if (start == std::string::npos) throw std::runtime_error("Header not found");
    start += header.size();
    size_t end = content.find(footer, start);
    if (end == std::string::npos) throw std::runtime_error("Footer not found");
    std::string block = content.substr(start, end - start);

    std::string base64Payload;
    bool inString = false;
    for (size_t i = 0; i < block.size(); ++i) 
    {
        char c = block[i];
        if (c == '"') 
        {
            inString = !inString;   // toggle on/off
            continue;
        }

        if (inString) {
            base64Payload += c;
        }
    }

    // remove whitespace just in case
    for (size_t i = 0; i < base64Payload.size(); ) {
        if (isspace((unsigned char)base64Payload[i]))
            base64Payload.erase(i, 1);
        else
            ++i;
    }

    std::cout << "EXTRACTED BASE64 SIZE = " << base64Payload.size() << std::endl;

    // start decode  
    base64::decoder decoder;
    std::istringstream encodedString(base64Payload);
    std::ostringstream decodedString(std::ios::binary);

    decoder.decode(encodedString, decodedString);

    std::string decoded = decodedString.str();

    std::cout << "DONE DECODING. SIZE = " << decoded.size() << std::endl;

    // hex dump
    // for (size_t i = 0; i < decoded.size(); ++i)
        // printf("%02x ", (unsigned char)decoded[i]);
    // printf("\n");

    // print ascii
    std::cout << "DECODED CONTENT \n";
    std::cout.write(decoded.data(), decoded.size());
    std::cout << std::endl;
}


int main(int argc, char ** argv)
{
  if ((argc < 2) || (argc > 4))
  {
    usage(argv[0]);
    return 1;
  }

  std::string option = argv[1];
  if (option == "--version")
  {
    std::cout << KIM_VERSION_STRING << std::endl;
    return 0;
  }
  else if (option != "-i" || argc != 4)
  {
    usage(argv[0]);
    exit(-1);
  }

  // open the input file in binary-mode
  std::string input = argv[2];
  std::ifstream instream(input.c_str(),
                         std::ios_base::in | std::ios_base::binary);
  if (!instream.is_open())
  {
    usage(argv[0], "Could not open input file " + input);
    exit(-1);
  }

  // open the output file in binary-mode
  std::string output = argv[3];
  std::ofstream outstream(output.c_str(), std::ios_base::out);
  if (!outstream.is_open())
  {
    usage(argv[0], "Could not open output file " + output);
    exit(-1);
  }

  std::string encodeFormatFileName = make_c_identifier(input);

  std::string header
      = "extern unsigned char " + encodeFormatFileName + "[] = \n\"";
  outstream.write(header.data(), header.length());

  base64::encoder E;

  E.encode(instream, outstream);
  std::string footer = "\";\nextern unsigned int " + encodeFormatFileName
                       + "_len = sizeof(" + encodeFormatFileName + ") - 1;\n";

  outstream.write(footer.data(), footer.length());
  outstream.close();

  decodeBase64FileInMemory(output);

  return 0;
}

#pragma once

#include <string>
#include <cpptoml/cpptoml.hpp>

namespace fs
{

void chdir(const std::string&);
void mkdir(const std::string&);
bool exists(const std::string&);
void remove(const std::string&);
void copy(const std::string& src, const std::string& dst);
bool is_regular(const std::string&);
std::string getcwd();
std::string realpath(const std::string&);
std::string append(const std::string&, const std::string&);
std::shared_ptr<cpptoml::table> get_toml_config(const std::string&);

} // namespace fs

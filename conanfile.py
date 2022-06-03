from pathlib import Path

from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, CMakeDeps, CMake

from conans.errors import ConanInvalidConfiguration
from conans.tools import Version
from conan.tools.files import files

required_conan_version = ">=1.46.2"


class CuraBuildEnvironemtConan(ConanFile):
    name = "cura-build-environment"
    description = "Building Cura dependencies"
    topics = ("conan", "python", "pypi", "pip")
    settings = "os", "compiler", "build_type", "arch"
    build_policy = "missing"

    def configure(self):
        self.options["boost"].header_only = True
        self.options["*"].shared = True
        self.options["arcus"].python_version = "3.10.4"

    def build_requirements(self):
        self.tool_requires("protobuf/3.17.1")

    def requirements(self):
        self.requires("protobuf/3.17.1")
        self.requires("clipper/6.4.2")
        self.requires("boost/1.78.0")
        self.requires("gtest/1.8.1")
        self.requires("nlopt/2.7.0")
        self.requires("rapidjson/1.1.0")
        self.requires("stb/20200203")
        self.requires("arcus/5.0.1-PullRequest0137.78@ultimaker/testing")

    def generate(self):
        cmake = CMakeDeps(self)
        cmake.build_context_activated = ["protobuf"]
        cmake.build_context_suffix = {"protobuf": "_BUILD"}

        cmake.generate()

        tc = CMakeToolchain(self)

        # Don't use Visual Studio as the CMAKE_GENERATOR
        if self.settings.compiler == "Visual Studio":
            tc.blocks["generic_system"].values["generator_platform"] = None
            tc.blocks["generic_system"].values["toolset"] = None

        tc.generate()

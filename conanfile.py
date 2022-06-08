import os

from jinja2 import Template

from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, CMakeDeps
from conan.tools.env import VirtualRunEnv
from conans.errors import ConanException

required_conan_version = ">=1.46.2"


class CuraBuildEnvironemtConan(ConanFile):
    name = "cura-build-environment"
    description = "Building Cura dependencies"
    topics = ("conan", "python", "pypi", "pip")
    settings = "os", "compiler", "build_type", "arch"
    build_policy = "missing"
    generators = "VirtualRunEnv"

    def layout(self):
        self.folders.source = "."
        try:
            build_type = str(self.settings.build_type)
        except ConanException:
            raise ConanException("'build_type' setting not defined, it is necessary")

        self.folders.build = f"cmake-build-{build_type.lower()}"
        self.folders.generators = os.path.join(self.folders.build, "conan")

    def configure(self):
        self.options["boost"].header_only = True
        self.options["*"].shared = True

    def requirements(self):
        self.requires("clipper/6.4.2")
        self.requires("boost/1.78.0")
        self.requires("nlopt/2.7.0")
        self.requires("curaengine/5.0.1-CURA-9365-fix-building-cura-main.1+58@ultimaker/cura-9365")

    def generate(self):
        with open(os.path.join(self.source_folder, "cmake", "pyinstaller.cmake.jinja"), "r") as f:
            pyinstaller_cmake = Template(f.read())

        run_env = VirtualRunEnv(self)
        env = run_env.environment()
        envvars = env.vars(self, scope = "run")
        with open(os.path.join(self.source_folder, "cmake", "pyinstaller.cmake"), "w") as f:
            f.write(pyinstaller_cmake.render(envs = envvars, curaengine_bindir = self.deps_cpp_info["curaengine"].bindirs[0]))

        cmake = CMakeDeps(self)
        cmake.generate()

        tc = CMakeToolchain(self)

        # Don't use Visual Studio as the CMAKE_GENERATOR
        if self.settings.compiler == "Visual Studio":
            tc.blocks["generic_system"].values["generator_platform"] = None
            tc.blocks["generic_system"].values["toolset"] = None

        tc.generate()

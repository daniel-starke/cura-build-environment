import os

from pathlib import Path
from jinja2 import Template

from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, CMakeDeps
from conan.tools.env import VirtualRunEnv
from conans import tools
from conans.errors import ConanException

required_conan_version = ">=1.48"


class CuraBuildEnvironemtConan(ConanFile):
    name = "cura-build-environment"
    description = "Building Cura dependencies"
    topics = ("conan", "python", "pypi", "pip")
    settings = "os", "compiler", "build_type", "arch"
    build_policy = "missing"
    generators = "VirtualRunEnv"
    short_paths = True

    @property
    def conandata_version(self):
        version = tools.Version(self.version)
        version = f"{version.major}.{version.minor}.{version.patch}-{version.prerelease}"
        if version in self.conan_data:
            return version
        return "dev"

    def set_version(self):
        if not self.version:
            if "CURA_VERSION" in os.environ:
                self.version = os.environ["CURA_VERSION"]
            else:
                self.version = "dev"

    def layout(self):
        self.folders.source = "."
        try:
            build_type = str(self.settings.build_type)
        except ConanException:
            raise ConanException("'build_type' setting not defined, it is necessary")

        self.folders.build = f"cmake-build-{build_type.lower()}"
        self.folders.generators = os.path.join(self.folders.build, "conan")

    def build_requirements(self):
        self.tool_requires("ninja/[>=1.10.0]")
        self.tool_requires("cmake/[>=3.23.0]")

    def source(self):
        username = os.environ.get("GIT_USERNAME", None)
        password = os.environ.get("GIT_PASSWORD", None)
        for git_src in self.conan_data[self.version]["git"].values():
            folder = Path(self.source_folder, git_src["directory"])
            should_clone = folder.exists()
            git = tools.Git(folder = folder, username = username, password = password)
            if should_clone:
                git.checkout(git_src["branch"])
            else:
                git.clone(url = git_src["url"], branch = git_src["branch"], shallow = True)

    def generate(self):
        pass

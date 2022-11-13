#import chimera
"""

def printMethods(obj):
    object_methods = [method_name for method_name in dir(obj)
                    if callable(getattr(obj, method_name))]
    print(object_methods)


print("hello")

object_methods = [method_name for method_name in dir(chimera)
                  if callable(getattr(chimera, method_name))]

for x in object_methods:
    if x.find("save") != -1:
        print(x) 
#print(object_methods)
opened = chimera.openModels.open("../proteins/pdb_files/MGYP002175132816.pdb")
print(opened[0])
printMethods(chimera.exportssource activate pychimera)
# chimera.exports.register(type, glob, suffix, command, notes=None)
# chimera.exports.register("OBJ", "obj", "obj", command, "These are notes for fake notes")

for m in chimera.openModels.list():
    print(m)
chimera.exports.doExportCommand("VRML", "test.wrl")

#import Midas
#Midas.export("test.obj", "OBJ",list=False)
"""


import sys
import subprocess
import pymeshlab

if (len(sys.argv) != 2):
    print("Must be of form convert_pdb.py file.pdb")

pdb_filepath = sys.argv[1]

filepath_tokens = pdb_filepath.split('/')
pdb_filename = filepath_tokens[len(filepath_tokens) - 1]
fname_tokens = pdb_filename.split('.')

print(fname_tokens)
assert(len(fname_tokens) == 2)
assert(fname_tokens[len(fname_tokens) - 1] == 'pdb')

#list_files = subprocess.run(["ls", "-l"])

# chimera.nogui = False
# chimera.viewer = chimera.LensViewer()
# chimera.initializeGraphics()
# ppened_models = chimera.openModels.open(pdb_filepath)
# chimera.exports.doExportCommand("VRML", "test.wrl")
#f = open(pdb_filepath, "r")
#wrl_file = open("temp.wrl", "w")
#pdb2wrl = subprocess.run(["perl", "pdb2wrl.pl"], stdout=wrl_file, input=f.read().encode())
#wrl_file.close()

ms = pymeshlab.MeshSet()

ms.load_new_mesh(pdb_filepath)
#ms.generate_convex_hull()
ms.save_current_mesh(fname_tokens[0] + '.obj')


# print("The exit code was: %d" % pdb2wrl.returncode)
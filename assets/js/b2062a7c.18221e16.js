"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[270],{52685:e=>{e.exports=JSON.parse('{"functions":[{"name":"byPredicate","desc":"Travels up through the ancestry of `root` until it finds an Instance that passes the conditions of the predicate.\\n\\n```lua\\nlocal found = byPredicate(workspace.Terrain, function(ancestor)\\n\\treturn ancestor.Name ~= \\"NotThisName\\"\\nend):expect()\\n```","params":[{"name":"root","desc":"","lua_type":"Instance"},{"name":"predicate?","desc":"The conditions under which the search has successfully found a result. The second parameter represents depth.","lua_type":"(Instance, number) -> boolean"}],"returns":[{"desc":"The result of the search wrapped as a promise.","lua_type":"Promise<Instance?>"}],"function_type":"static","source":{"line":92,"path":"src/FindFirstAncestor.luau"}},{"name":"byName","desc":"Travels up through the ancestry of `root` until it finds an Instance that matches the provided name.\\n\\n```lua\\nlocal found = byName(workspace.Terrain, \\"Workspace\\"):expect()\\n```","params":[{"name":"root","desc":"","lua_type":"Instance"},{"name":"name","desc":"The name of the Instance being searched for.","lua_type":"string"}],"returns":[{"desc":"The result of the search wrapped as a promise.","lua_type":"Promise<Instance?>"}],"function_type":"static","source":{"line":110,"path":"src/FindFirstAncestor.luau"}},{"name":"ofClass","desc":"Travels up through the ancestry of `root` until it finds an Instance that matches the provided ClassName.\\n\\n```lua\\nlocal found = ofClass(workspace.Terrain, \\"Workspace\\"):expect()\\n```","params":[{"name":"root","desc":"","lua_type":"Instance"},{"name":"className","desc":"The class name of the Instance being searched for.","lua_type":"string"}],"returns":[{"desc":"The result of the search wrapped as a promise.","lua_type":"Promise<Instance?>"}],"function_type":"static","source":{"line":128,"path":"src/FindFirstAncestor.luau"}},{"name":"whichIsA","desc":"Travels up through the ancestry of `root` until it finds an Instance with a class equivalent to or a subclass of a given class.\\n\\n```lua\\nlocal found = whichIsA(workspace.Terrain, \\"WorldRoot\\"):expect()\\n```","params":[{"name":"root","desc":"","lua_type":"Instance"},{"name":"className","desc":"The class name of the Instance being searched for.","lua_type":"string"}],"returns":[{"desc":"The result of the search wrapped as a promise.","lua_type":"Promise<Instance?>"}],"function_type":"static","source":{"line":146,"path":"src/FindFirstAncestor.luau"}},{"name":"byDepth","desc":"Travels up through the ancestry of `root` by `depth` number of steps.\\n\\n```lua\\nlocal found = byDepth(workspace.Terrain, 2):expect()\\nprint(found == game)\\n```","params":[{"name":"root","desc":"","lua_type":"Instance"},{"name":"depth","desc":"How many steps upwards should be travelled","lua_type":"number"}],"returns":[{"desc":"The result of the search wrapped as a promise.","lua_type":"Promise<Instance?>"}],"function_type":"static","source":{"line":165,"path":"src/FindFirstAncestor.luau"}}],"properties":[],"types":[],"name":"FindFirstAncestor","desc":"FindFirstAncestor is a set of functions that search for ancestors conditionally.","source":{"line":14,"path":"src/FindFirstAncestor.luau"}}')}}]);
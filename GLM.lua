-- The MIT License (MIT)
--
-- Copyright (c) 2016 Indium Games (www.indiumgames.fi)
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

-- luacheck: ignore GLM

-- SWIG creates operator functions in:
--  GLM.__add, GLM.__sub, GLM.__mul and GLM.__div
--
-- In order to make these work as intended, we need to point the GLM type
--  metatables to the operator functions.

rawset(GLM, "mat2", GLM.mat2 or GLM.mat2x2)
rawset(GLM, "mat3", GLM.mat3 or GLM.mat3x3)
rawset(GLM, "mat4", GLM.mat4 or GLM.mat4x4)


-- Get metatables for the GLM types
local metatables = {
    GLM.vec2   and getmetatable(GLM.vec2)[".instance"]   or nil,
    GLM.vec3   and getmetatable(GLM.vec3)[".instance"]   or nil,
    GLM.vec4   and getmetatable(GLM.vec4)[".instance"]   or nil,
    GLM.ivec2  and getmetatable(GLM.ivec2)[".instance"]  or nil,
    GLM.ivec3  and getmetatable(GLM.ivec3)[".instance"]  or nil,
    GLM.ivec4  and getmetatable(GLM.ivec4)[".instance"]  or nil,
    GLM.uvec2  and getmetatable(GLM.uvec2)[".instance"]  or nil,
    GLM.uvec3  and getmetatable(GLM.uvec3)[".instance"]  or nil,
    GLM.uvec4  and getmetatable(GLM.uvec4)[".instance"]  or nil,
    GLM.mat2   and getmetatable(GLM.mat2)[".instance"]   or nil,
    GLM.mat2x2 and getmetatable(GLM.mat2x2)[".instance"] or nil,
    GLM.mat2x3 and getmetatable(GLM.mat2x3)[".instance"] or nil,
    GLM.mat2x4 and getmetatable(GLM.mat2x4)[".instance"] or nil,
    GLM.mat3x2 and getmetatable(GLM.mat3x2)[".instance"] or nil,
    GLM.mat3   and getmetatable(GLM.mat3)[".instance"]   or nil,
    GLM.mat3x3 and getmetatable(GLM.mat3x3)[".instance"] or nil,
    GLM.mat3x4 and getmetatable(GLM.mat3x4)[".instance"] or nil,
    GLM.mat4x2 and getmetatable(GLM.mat4x2)[".instance"] or nil,
    GLM.mat4x3 and getmetatable(GLM.mat4x3)[".instance"] or nil,
    GLM.mat4   and getmetatable(GLM.mat4)[".instance"]   or nil,
    GLM.mat4x4 and getmetatable(GLM.mat4x4)[".instance"] or nil,
    GLM.quat   and getmetatable(GLM.quat)[".instance"]   or nil,
}

-- Add operator metamethods to the type's metatable
for _, metatable in pairs(metatables) do
    metatable.__add = GLM.__add
    metatable.__sub = GLM.__sub
    metatable.__mul = GLM.__mul
    metatable.__div = GLM.__div
    
    metatable.__mod = GLM.mod
    metatable.__pow = GLM.pow
    
    local mul = GLM.__mul
    metatable.__unm = function (x)
        return mul(x, -1)
    end
    
    local length = metatable[".fn"].length
    if length then
        metatable.__len = function (x)
            return length(x)
        end
    end
end


--!
--! Define custom rotation functions.
--!
local function DefineCustomFunctions()
    local abs = math.abs
    local acos = math.acos
    local cos = math.cos
    local sin = math.sin
    
    local dot = GLM.dot
    local length = GLM.length
    local normalize = GLM.normalize
    local vec3 = GLM.vec3
    
    function GLM.angle(v1, v2)
        if length(v1) == 0 then
            error("v1 has length 0", 2)
        elseif length(v2) == 0 then
            error("v2 has length 0", 2)
        end
        
        v1 = normalize(v1)
        v2 = normalize(v2)
        
        return acos(
            abs(dot(v1, v2))
        )
    end
    
    function GLM.rotateX(v, angle)
        local angleCos = cos(angle)
        local angleSin = sin(angle)
        
        return vec3(
            v.x,
            v.y * angleCos - v.z * angleSin,
            v.y * angleSin + v.z * angleCos
        )
    end
    
    function GLM.rotateY(v, angle)
        local angleCos = cos(angle)
        local angleSin = sin(angle)
        
        return vec3(
            v.x * angleCos + v.z * angleSin,
            v.y,
            -v.x * angleSin + v.z * angleCos
        )
    end
    
    function GLM.rotateZ(v, angle)
        local angleCos = cos(angle)
        local angleSin = sin(angle)
        
        return vec3(
            v.x * angleCos - v.y * angleSin,
            v.x * angleSin + v.y * angleCos,
            v.z
        )
    end
end


--!
--! Define a vector swizzle metamethod.
--!
local function DefineVectorSwizzle(vectorType, componentCount)
    local vectorClass = GLM[vectorType .. componentCount]
    
    if not vectorClass then
        return
    end
    
    local vectorMetatable = getmetatable(vectorClass)[".instance"]
    
    local swig__index = vectorMetatable.__index
    
    vectorMetatable.__index = function (self, key)
        if type(key) == "string" and #key < 5 then
            local swizzleFunc = getmetatable(self)[".fn"][key]
            
            if swizzleFunc then
                return swizzleFunc(self)
            end
        end
        
        return swig__index(self, key)
    end
end


DefineCustomFunctions()

DefineVectorSwizzle("vec", 2)
DefineVectorSwizzle("vec", 3)
DefineVectorSwizzle("vec", 4)
DefineVectorSwizzle("ivec", 2)
DefineVectorSwizzle("ivec", 3)
DefineVectorSwizzle("ivec", 4)
DefineVectorSwizzle("uvec", 2)
DefineVectorSwizzle("uvec", 3)
DefineVectorSwizzle("uvec", 4)

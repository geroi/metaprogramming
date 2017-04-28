#Ruby metaprogramming
#
#Part I
#
Object.new.methods.grep(/re/)
# => [:replace]
def hello_world(name, last_name)
    puts "name:#{name} - #{last_name}"
end

obj.instance_variables


#
SomeClass.instance_methods(false)
# => only self methods of instance NO inherited

module M
    include A
    include B
    include C
end
M.ancestors
# => [M, C, B, A]


module M2
    include B    
    include M
end

M2.ancestors
# => [M2, M, C, B, A]

define_method :name do |arg1, arg2|
    arg2 + arg2
end

o.instance_variable_set(@a, 2)
o.instance_variables
# => [@a=2]

def respond_to_missing?(method_name, include_private = false)
    delegated_obj.respond_to?(:name) || super
end

# => checks responds responds responds to missing method names, such as Ghost methods
class A
end

A.lass_eval do
    def meth
        "class eval applies to all the class instances"
    end
end

A.new.meth # => "class eval applies to all the class instances"

A.instance_eval do
    def in_meth
        "instance eval applies to current object"
    end
end

A.in_meth # => "instance eval applies to current object"

####

class EmptyClass < BasicObject
end

# Scope gates
class K; end
module K; end
def k; end

  
# Flat scoping for using variables
# Scope sharing
# in the object all instance variables are binded only to this object
# so to pass other objects instance variables u must use instance_exec - it can accept variables
# instance_eval {}
# instance_exec() {}

my_var = "My variable"
@other_scope_var = 'var'

NewClass = MyClass.new do 
  define_method :meth do |var1|
    @yo_var = var1 + my_var
  end
end
    
NewClass.instance_exec(@other_scope_var) do |osv|
        define_method :meth_with_in_var do
        @yo_var + osv
    end
end

#
#Proc is loyal to arity
#But Proc return - treturns upwards
#
#Lambda is strict checking argunets
#But returning the result from itself
#
#
class A
    def initialize
        @a = 9
    end

    def meth
      @a
    end
end
# Unbound methods can be bind to object with same class or descendant
m = A.new.method(:meth)
m.unbind
B = Class.new(A)
m.bind(B.new)

####
#
A_one = Class.new do
    def bind_meth; end
end

m_from_a = A_one.new.method(:bind_meth)
B_one = Class.new do
    define_method :meth_from_a, &m_from_a
end

# class_eval
# class_exec
# instance_eval
# instance_exec
#
class MyStruct
    def self.new(*attrs)
        Class.new do
            raise unless attrs.all?{|s| s.is_a?(Symbol)}
            attr_accessor(*attrs)

            define_method(:initialize) do |*attr_values|
                attrs.each.with_index { |attr, idx| instance_variable_set("@#{attr.to_s}".to_sym, attr_values[idx])}
            end
        end    
    end
end
       

#######################################
# i want DSL for events like this
#/predicates.rb
#
# setup do
#   company = Company.first
#   saat_poll = @company.saat_poll
# end
#
# predicate "if company is not paid", for: first_step do
#   assert_equal @company.paid?, true 
# end
########################################

lambda do
    setups = []
    predicates = []

    Kernel.send :define_method, :setup do |&block|
        setups << block
    end

    Kernel.send :define_method, :predicate do |text, &predicate|
        predicates << OpenStruct.new(text: text, predicate: predicate)
    end

    Kernel.send :define_method, :each_setup do |&block|
        setups.each { |setup| setup.call(&block) }
    end

    Kernel.send :define_method, :each_predicate do |&block|
        predicates.each { |predicate| predicate.call(&block) }
    end

    Kernel.send :define_method, :print_result do |&blk|
        str = hsh.text.ljust(100, '.')
        ok = begin
                !hsh.predicate.call
             rescue
                false
             end ? "PASS" : "FAIL"
        puts(str << ok)
    end
end.call

load('predicates.rb')

each_predicate do |predicate|
    each_setup do |setup|
        setup.call
    end
    print_result(predicate)
end

##########
# define instance method in a class
#
def add_method_to_class(klass)
    klass.class_eval do
        define_method(:m) {}
    end
end

############
# class instance variables class A; @a=1; end
# class variables class A; @@a = 2; end
# class variables are HIERARCHY variables and accessed by objects and subtypes and subtype objects
#

##############
# special syntax puts you into SINGLETON CLASS FOR AN OBJECT
#
o = Object.new
class << o
    def single_meth
    end
end
o.single_meth
# => nil
o.class.instance_methods.include?(:single_meth)
# => false
o.singleton_class.instance_methods
# => [:single_meth]


# Singleton class of a Class - inherits class's superclass's singleton class
class << C
    def c_singl_meth; end
end
C.singleton_class # => nil
s_C = C.singleton_class # => s_C
class D < C; end

D.c_singl_meth # => nil - method exists
s_D = D.singleton_class # => s_D
s_D.superclass == s_C # => true

##################
# object.instance_eval {} 
#  opens the object's singleton class
# ####################
#
#
#
# refine allows safe monkey patching
#
module StringRefinement
    refine String do
        def length
            super > 5 ? "big" : "small"
        end
    end
end

using StringRefinement

###################

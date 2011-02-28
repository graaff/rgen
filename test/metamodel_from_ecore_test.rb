$:.unshift File.join(File.dirname(__FILE__),"..","test")

require 'metamodel_builder_test'
require 'rgen/ecore/ecore_to_ruby'

# this test suite runs all the tests of MetamodelBuilderTest with the TestMetamodel 
# replaced by the result of feeding its ecore model through ECoreToRuby
# 
class MetamodelFromEcoreTest < MetamodelBuilderTest
  
  # clone the ecore model, because it will be modified below
  test_ecore = Marshal.load(Marshal.dump(TestMetamodel.ecore))
  # some EEnum types are not hooked into the EPackage because they do not
  # appear with a constant assignment in TestMetamodel
  # fix this by explicitly assigning the ePackage
  # also fix the name of anonymous enums
  test_ecore.eClassifiers.find{|c| c.name == "SimpleClass"}.
    eAttributes.select{|a| a.name == "kind" || a.name == "kindWithDefault"}.each{|a|
      a.eType.name = "KindType"
      a.eType.ePackage = test_ecore}
  test_ecore.eClassifiers.find{|c| c.name == "ManyAttrClass"}.
    eAttributes.select{|a| a.name == "enums"}.each{|a|
      a.eType.name = "ABCEnum"
      a.eType.ePackage = test_ecore}

  MetamodelFromEcore = RGen::ECore::ECoreToRuby.new.create_module(test_ecore)

  def mm
    MetamodelFromEcore
  end
end


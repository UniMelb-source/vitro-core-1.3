<%-- $This file is distributed under the terms of the license in /doc/license.txt$ --%>

<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Arrays" %>

<%@ page import="com.hp.hpl.jena.rdf.model.Model" %>
<%@ page import="com.hp.hpl.jena.vocabulary.XSD" %>

<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.ObjectPropertyStatement"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.VitroVocabulary" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.configuration.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.web.MiscWebUtils" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.freemarker.UrlBuilder.JavaScript" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.freemarker.UrlBuilder.Css" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.utils.FrontEndEditingUtils"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.utils.FrontEndEditingUtils.EditMode"%>

<%@ page import="org.apache.commons.logging.Log" %>
<%@ page import="org.apache.commons.logging.LogFactory" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core"%>
<%@ taglib prefix="v" uri="http://vitro.mannlib.cornell.edu/vitro/tags" %>

<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.configuration.Field"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.elements.DateTimeWithPrecision"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.configuration.validators.DateTimeIntervalValidation"%>

<%!
    public static Log log = LogFactory.getLog("edu.cornell.mannlib.vitro.webapp.jsp.edit.forms.addCustomRole.jsp");
    public static String nodeToRoleProp = "http://vivoweb.org/ontology/core#relatedRole";
%>

<c:set var="numDateFields">${! empty param.numDateFields ? param.numDateFields : 2 }</c:set>

<%

    VitroRequest vreq = new VitroRequest(request);

    String subjectUri = vreq.getParameter("subjectUri");
    String predicateUri = vreq.getParameter("predicateUri");
    String objectUri = vreq.getParameter("objectUri");

	Individual obj = (Individual) request.getAttribute("object");

    EditMode mode = FrontEndEditingUtils.getEditMode(request, nodeToRoleProp);

     if( mode == EditMode.ADD ) {
    %> <c:set var="editMode" value="add"/><%
    } else if(mode == EditMode.EDIT){
     %> <c:set var="editMode" value="edit"/><%
    } else if(mode == EditMode.REPAIR){
     %> <c:set var="editMode" value="repair"/><%
    }

    WebappDaoFactory wdf = vreq.getWebappDaoFactory();
    vreq.setAttribute("defaultNamespace", ""); //empty string triggers default new URI behavior

    Individual subject = (Individual) request.getAttribute("subject");
    String subjectName = subject.getName();
    vreq.setAttribute("subjectUriJson", MiscWebUtils.escape(subjectUri));

    vreq.setAttribute("stringDatatypeUriJson", MiscWebUtils.escape(XSD.xstring.toString()));
    vreq.setAttribute("gYearDatatypeUriJson", MiscWebUtils.escape(XSD.gYear.toString()));

    String intDatatypeUri = XSD.xint.toString();
    vreq.setAttribute("intDatatypeUri", intDatatypeUri);
    vreq.setAttribute("intDatatypeUriJson", MiscWebUtils.escape(intDatatypeUri));

%>

<c:set var="vivoOnt" value="http://vivoweb.org/ontology" />
<c:set var="vivoCore" value="${vivoOnt}/core#" />
<c:set var="rdfs" value="<%= VitroVocabulary.RDFS %>" />
<c:set var="rdf" value="<%= VitroVocabulary.RDF %>" />
<c:set var="vitro" value="<%= VitroVocabulary.vitroURI %>" />
<c:set var="label" value="${rdfs}label" />
<c:set var="infoResourceClassUri" value="${vivoCore}InformationResource" />

<c:set var="startYearPred" value="${vivoCore}startYear" />
<c:set var="endYearPred" value="${vivoCore}endYear" />
<c:set var="dateTimeValueType" value="${vivoCore}DateTimeValue"/>
<c:set var="dateTimePrecision" value="${vivoCore}dateTimePrecision"/>
<c:set var="dateTimeValue" value="${vivoCore}dateTime"/>

<c:set var="roleToInterval" value="${vivoCore}dateTimeInterval"/>
<c:set var="intervalType" value="${vivoCore}DateTimeInterval"/>
<c:set var="intervalToStart" value="${vivoCore}start"/>
<c:set var="intervalToEnd" value="${vivoCore}end"/>

<v:jsonset var="newRoleTypeAssertion">
    @prefix core: <${vivoCore}> .
    @prefix rdf:  <${rdf}> .
    @prefix rdfs:  <${rdfs}> .

    ?roleUri core:roleOf ?personUri .
    ?personUri core:hasRole ?roleUri .
    
    ?roleUri core:researcherRoleOf ?personUri .
    ?personUri core:hasResearcherRole ?roleUri .
    
    ?roleUri core:roleIn ?activity .
    ?activity core:relatedRole ?roleUri .
</v:jsonset>

<v:jsonset var="n3ForNewRole">
    @prefix rdf:  <${rdf}> .
    ?roleUri rdf:type ?roleTypeUri .    
</v:jsonset>

<v:jsonset var="n3ForStart">
    ?roleUri      <${roleToInterval}> ?intervalNode .
    ?intervalNode  <${type}> <${intervalType}> .
    ?intervalNode <${intervalToStart}> ?startNode .
    ?startNode  <${type}> <${dateTimeValueType}> .
    ?startNode  <${dateTimeValue}> ?startField-value .
    ?startNode  <${dateTimePrecision}> ?startField-precision .
</v:jsonset>

<v:jsonset var="n3ForEnd">
    ?roleUri      <${roleToInterval}> ?intervalNode .
    ?intervalNode  <${type}> <${intervalType}> .
    ?intervalNode <${intervalToEnd}> ?endNode .
    ?endNode  <${type}> <${dateTimeValueType}> .
    ?endNode  <${dateTimeValue}> ?endField-value .
    ?endNode  <${dateTimePrecision}> ?endField-precision .
</v:jsonset>

<%-- ---------------------------------------------------------------------- --%>

<v:jsonset var="existingIntervalNodeQuery" >
    SELECT ?existingIntervalNode WHERE {
          ?roleUri <${roleToInterval}> ?existingIntervalNode .
          ?existingIntervalNode <${type}> <${intervalType}> . }
</v:jsonset>

 <v:jsonset var="existingStartNodeQuery" >
    SELECT ?existingStartNode WHERE {
      ?roleUri <${roleToInterval}> ?intervalNode .
      ?intervalNode <${type}> <${intervalType}> .
      ?intervalNode <${intervalToStart}> ?existingStartNode .
      ?existingStartNode <${type}> <${dateTimeValueType}> .}
</v:jsonset>

<v:jsonset var="existingStartDateQuery" >
    SELECT ?existingDateStart WHERE {
     ?roleUri <${roleToInterval}> ?intervalNode .
     ?intervalNode <${type}> <${intervalType}> .
     ?intervalNode <${intervalToStart}> ?startNode .
     ?startNode <${type}> <${dateTimeValueType}> .
     ?startNode <${dateTimeValue}> ?existingDateStart . }
</v:jsonset>

<v:jsonset var="existingStartPrecisionQuery" >
    SELECT ?existingStartPrecision WHERE {
      ?roleUri <${roleToInterval}> ?intervalNode .
      ?intervalNode <${type}> <${intervalType}> .
      ?intervalNode <${intervalToStart}> ?startNode .
      ?startNode <${type}> <${dateTimeValueType}> .
      ?startNode <${dateTimePrecision}> ?existingStartPrecision . }
</v:jsonset>

 <v:jsonset var="existingEndNodeQuery" >
    SELECT ?existingEndNode WHERE {
      ?roleUri <${roleToInterval}> ?intervalNode .
      ?intervalNode <${type}> <${intervalType}> .
      ?intervalNode <${intervalToEnd}> ?existingEndNode .
      ?existingEndNode <${type}> <${dateTimeValueType}> .}
</v:jsonset>

<v:jsonset var="existingEndDateQuery" >
    SELECT ?existingEndDate WHERE {
     ?roleUri <${roleToInterval}> ?intervalNode .
     ?intervalNode <${type}> <${intervalType}> .
     ?intervalNode <${intervalToEnd}> ?endNode .
     ?endNode <${type}> <${dateTimeValueType}> .
     ?endNode <${dateTimeValue}> ?existingEndDate . }
</v:jsonset>

<v:jsonset var="existingEndPrecisionQuery" >
    SELECT ?existingEndPrecision WHERE {
      ?roleUri <${roleToInterval}> ?intervalNode .
      ?intervalNode <${type}> <${intervalType}> .
      ?intervalNode <${intervalToEnd}> ?endNode .
      ?endNode <${type}> <${dateTimeValueType}> .
      ?endNode <${dateTimePrecision}> ?existingEndPrecision . }
</v:jsonset>

<%-- ---------------------------------------------------------------------- --%>

<v:jsonset var="existingNameQuery" >
  PREFIX core: <${vivoCore}>
  PREFIX rdfs: <${rdfs}>
  
  SELECT ?existingName WHERE {
    ?activity core:relatedRole ?roleUri .
    ?roleUri core:roleOf ?personUri .
    ?personUri rdfs:label ?existingName .
  }
</v:jsonset>

<v:jsonset var="existingPersonTypeQuery" >
  PREFIX core: <${vivoCore}>
  PREFIX rdf: <${rdf}>
  PREFIX vitro:  <${vitro}>

  SELECT ?existingPersonType WHERE {
    ?activity core:relatedRole ?roleUri .
    ?roleUri core:roleOf ?personUri .
    ?personUri vitro:mostSpecificType ?existingPersonType .

        FILTER (
            ?existingPersonType = core:FacultyMember ||
            ?existingPersonType = core:Librarian ||
            ?existingPersonType = core:EmeritusLibrarian ||
            ?existingPersonType = core:NonAcademic ||
            ?existingPersonType = core:NonFacultyAcademic ||
            ?existingPersonType = core:EmeritusFaculty ||
            ?existingPersonType = core:Student
            )
  }
</v:jsonset>

<v:jsonset var="existingRoleTypeQuery" >
  PREFIX core: <${vivoCore}>
  PREFIX rdf: <${rdf}>
  PREFIX vitro:  <${vitro}>

  SELECT ?existingRoleType WHERE {
    ?activity core:relatedRole ?roleUri .
    ?roleUri vitro:mostSpecificType ?existingRoleType .

        FILTER (
            ?existingRoleType = core:ResearcherRole ||
            ?existingRoleType = core:InvestigatorRole ||
            ?existingRoleType = core:PrincipalInvestigatorRole ||
            ?existingRoleType = core:CoPrincipalInvestigatorRole
            )
  }
</v:jsonset>

<c:set var="personTypeLiteralOptions">
    ["", "Select type"],
    [ "http://vivoweb.org/ontology/core#FacultyMember", "Faculty Member" ],
    [ "http://vivoweb.org/ontology/core#Librarian", "Librarian" ],
    [ "http://vivoweb.org/ontology/core#EmeritusLibrarian", "Librarian Emeritus " ],
    [ "http://vivoweb.org/ontology/core#NonAcademic", "Non-Academic" ],
    [ "http://vivoweb.org/ontology/core#NonFacultyAcademic", "Non-Faculty Academic" ],
    [ "http://vivoweb.org/ontology/core#EmeritusFaculty", "Emeritus Faculty Member" ],
    [ "http://vivoweb.org/ontology/core#Student", "Student" ]
</c:set>

<c:set var="roleTypeLiteralOptions">
    ["", "Select type"],
    [ "http://vivoweb.org/ontology/core#ResearcherRole", "Researcher" ],
    [ "http://vivoweb.org/ontology/core#InvestigatorRole", "Investigator" ],
    [ "http://vivoweb.org/ontology/core#PrincipalInvestigatorRole", "Principal Investigator" ],
    [ "http://vivoweb.org/ontology/core#CoPrincipalInvestigatorRole", "Co-Principal Investigator" ]
</c:set>

<c:set var="editjson" scope="request">
{
    "formUrl" : "${formUrl}",
    "editKey" : "${editKey}",
    "urlPatternToReturnTo" : "/individual",

    "subject"   : ["activity", "${subjectUriJson}" ],
    "predicate" : ["predicate", "${predicateUriJson}" ],
    "object"    : ["roleUri", "${objectUriJson}", "URI" ],

    "n3required"    : [ "${n3ForNewRole}" ],

    "n3optional"    : [ "${newRoleTypeAssertion}", "${n3ForStart}", "${n3ForEnd}" ],

    "newResources"  : { "roleUri" : "${defaultNamespace}",
                        "intervalNode" : "${defaultNamespace}",
                        "startNode" : "${defaultNamespace}",
                        "endNode" : "${defaultNamespace}" },

    "urisInScope"    : { },
    "literalsInScope": { },
    "urisOnForm"     : [ "personUri", "roleTypeUri" ],
    "literalsOnForm" : [ "personName" ],
    "filesOnForm"    : [ ],
    "sparqlForLiterals" : { },
    "sparqlForUris" : {  },
    "sparqlForExistingLiterals" : {
        "personName"         : "${existingNameQuery}",
        "startField-value"   : "${existingStartDateQuery}",
        "endField-value"     : "${existingEndDateQuery}"
    },
    "sparqlForExistingUris" : {
        "personType"            : "${existingPersonTypeQuery}" ,
        "roleTypeUri"           : "${existingRoleTypeQuery}" ,
        "intervalNode"          : "${existingIntervalNodeQuery}",
        "startNode"             : "${existingStartNodeQuery}",
        "endNode"               : "${existingEndNodeQuery}",
        "startField-precision"  : "${existingStartPrecisionQuery}",
        "endField-precision"    : "${existingEndPrecisionQuery}"
    },
    "fields" : {
      "personType" : {
         "newResource"      : "false",
         "validators"       : [ ],
         "optionsType"      : "HARDCODED_LITERALS",
         "literalOptions"   : [ ${personTypeLiteralOptions} ],
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : [ "" ]
      },
      "roleTypeUri" : {
         "newResource"      : "false",
         "validators"       : [ ],
         "optionsType"      : "HARDCODED_LITERALS",
         "literalOptions"   : [ ${roleTypeLiteralOptions} ],
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : [ "${newRoleTypeAssertion}" ]
      },
      "personUri" : {
         "newResource"      : "true",
         "validators"       : [ ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [ ],
         "predicateUri"     : "",
         "objectClassUri"   : "${personClassUriJson}",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : [""]
      },
      "startField" : {
         "newResource"      : "false",
         "validators"       : [ ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [ ],
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : [ "${n3ForStart}" ]
      },
      "endField" : {
         "newResource"      : "false",
         "validators"       : [ ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [ ],
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : ["${n3ForEnd}" ]
      }
  }
}
</c:set>

<%
    log.debug(request.getAttribute("editjson"));

    EditConfiguration editConfig = EditConfiguration.getConfigFromSession(session,request);
    if (editConfig == null) {
        editConfig = new EditConfiguration((String) request.getAttribute("editjson"));
        EditConfiguration.putConfigInSession(editConfig,session);

        //set up date time edit elements
        Field startField = editConfig.getField("startField");
        startField.setEditElement(
                new DateTimeWithPrecision(startField,
                        VitroVocabulary.Precision.YEAR.uri(),
                        VitroVocabulary.Precision.NONE.uri()));
        Field endField = editConfig.getField("endField");
        endField.setEditElement(
                new DateTimeWithPrecision(endField,
                        VitroVocabulary.Precision.YEAR.uri(),
                        VitroVocabulary.Precision.NONE.uri()));
    }

    editConfig.addValidator(new DateTimeIntervalValidation("startField","endField") );

    //editConfig.addValidator(new PersonHasPublicationValidator());

    Model model = (Model) application.getAttribute("jenaOntModel");

    if (objectUri != null) { // editing existing (in this case, only repair is currently provided by the form)
        editConfig.prepareForObjPropUpdate(model);
    } else { // adding new
        editConfig.prepareForNonUpdate(model);
    }

    // Return to person, not publication. See NIHVIVO-1464.
  	// editConfig.setEntityToReturnTo("?personUri");

    List<String> customJs = new ArrayList<String>(Arrays.asList(JavaScript.JQUERY_UI.path(),
                                                                JavaScript.CUSTOM_FORM_UTILS.path(),
                                                                "/js/browserUtils.js",
                                                                "/edit/forms/js/customFormWithAutocomplete.js"
                                                               ));
    request.setAttribute("customJs", customJs);

    List<String> customCss = new ArrayList<String>(Arrays.asList(Css.JQUERY_UI.path(),
                                                                 Css.CUSTOM_FORM.path(),
                                                                 "/edit/forms/css/customFormWithAutocomplete.css"
                                                                ));
    request.setAttribute("customCss", customCss);
%>

<%-- Configure add vs. edit --%>
<c:choose>
    <c:when test='${editMode == "add"}'>
        <c:set var="titleVerb" value="Create" />
        <c:set var="submitButtonText" value="Role" />
    </c:when>
    <c:otherwise>
        <c:set var="titleVerb" value="Edit" />
        <c:set var="submitButtonText" value="Edit Role" />
    </c:otherwise>
</c:choose>

<c:set var="requiredHint" value="<span class='requiredHint'> *</span>" />
<c:set var="yearHint" value="<span class='hint'> (YYYY)</span>" />

<jsp:include page="${preForm}" />

<% if( mode == EditMode.ERROR ){ %>
 <div>This form is unable to handle the editing of this position because it is associated with
      multiple Position individuals.</div>
<% }else{ %>

<h2>${titleVerb} role entry for <%= subjectName %></h2>

<%@ include file="unsupportedBrowserMessage.jsp" %>

<%-- DO NOT CHANGE IDS, CLASSES, OR HTML STRUCTURE IN THIS FORM WITHOUT UNDERSTANDING THE IMPACT ON THE JAVASCRIPT! --%>
<form id="addRoleForm" class="customForm noIE67"  action="<c:url value="/edit/processRdfForm2.jsp"/>" >

    <p class="inline"><v:input type="select" label="Person Type ${requiredHint}" name="personType" id="typeSelector" /></p>

    <div class="fullViewOnly">       
       
	   <p><v:input type="text" id="relatedIndLabel" name="personName" label="Name ${requiredHint}" cssClass="acSelector" size="50" /></p>

	    <div class="acSelection">
	        <%-- RY maybe make this a label and input field. See what looks best. --%>
	        <p class="inline"><label></label><span class="acSelectionInfo"></span> <a href="<c:url value="/individual?uri=" />" class="verifyMatch">(Verify this match)</a></p>
	        <input type="hidden" id="personUri" name="personUri" class="acUriReceiver" value="" /> <!-- Field value populated by JavaScript -->
	    </div>

        <p class="inline"><v:input type="select" label="Role Type ${requiredHint}" name="roleTypeUri" id="roleTypeUri" /></p>        
        <br><br>
            
        <c:choose>
            <c:when test="${numDateFields == 1}">
                <v:input id="startField" label="Year ${yearHint}" size="7"/>
            </c:when>
            <c:otherwise>
                <h4 class="label">Years of Participation in ###</h4>
                <v:input id="startField" label="Start Year ${yearHint}" size="7"/>
                <v:input id="endField" label="End Year ${yearHint}" size="7"/>
            </c:otherwise>
        </c:choose>
    </div>

    <p class="submit"><v:input type="submit" id="submit" value="${submitButtonText}" cancel="true" /></p>

    <p id="requiredLegend" class="requiredHint">* required fields</p>
</form>

<c:url var="acUrl" value="/autocomplete?tokenize=true" />
<c:url var="sparqlQueryUrl" value="/ajax/sparqlQuery" />

<script type="text/javascript">
var customFormData  = {    
    sparqlQueryUrl: '${sparqlQueryUrl}',
    acUrl: '${acUrl}',
    submitButtonTextType: 'simple',
    editMode: '${editMode}',
    defaultTypeName: 'person' // used in repair mode to generate button text
};
</script>

<% } %>

<jsp:include page="${postForm}"/>
<%-- $This file is distributed under the terms of the license in /doc/license.txt$ --%>

<%-- Custom form for adding a publication to an author

Classes:
foaf:Person - the individual being edited
core:Authorship - primary new individual being created

Object properties (domain : range):

core:authorInAuthorship (Person : Authorship)
core:linkedAuthor (Authorship : Person) - inverse of authorInAuthorship

core:linkedInformationResource (Authorship : InformationResource)
core:informationResourceInAuthorship (InformationResource : Authorship) - inverse of linkedInformationResource

--%>

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

    /*
    There are 3 modes that this form can be in:
     1.  Add. There is a subject and a predicate but no position and nothing else.

     2. Repair a bad role node.  There is a subject, predicate and object but there is no individual on the
        other end of the object's core:linkedInformationResource stmt.  This should be similar to an add but the form should be expanded.

     3. Really bad node. Multiple core:authorInAuthorship statements.

     This form does not currently support normal edit mode where there is a subject, an object, and an individual on
     the other end of the object's core:linkedInformationResource statement. We redirect to the publication profile
     to edit the publication.
    */

    if( mode == EditMode.ADD ) {
       %> <c:set var="editMode" value="add"/><%
    } else if(mode == EditMode.EDIT){
        // Because it's edit mode, we already know there's one and only one statement
        ObjectPropertyStatement ops = obj.getObjectPropertyStatements(nodeToRoleProp).get(0);
        String roleUri = ops.getObjectURI();
        String forwardToIndividual = roleUri != null ? roleUri : objectUri;
        %>
        <jsp:forward page="/individual">
            <jsp:param value="<%= forwardToIndividual %>" name="uri"/>
        </jsp:forward>
        <%
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

<%-- Unlike other custom forms, this form does not allow edits of existing authors, so there are no
SPARQL queries for existing values. --%>

<v:jsonset var="newRoleTypeAssertion">
    ?roleUri a ?roleTypeUri .
    ?roleUri core:roleOf ?personUri .

    ?personUri core:hasRole ?roleUri .
    ?roleUri core:relatedRole ?activity .
</v:jsonset>

<v:jsonset var="n3ForNewRole">
    @prefix core: <${vivoCore}> .
    ?roleUri a core:Role .
</v:jsonset>

<v:jsonset var="n3ForStart">
    ?role      <${roleToInterval}> ?intervalNode .
    ?intervalNode  <${type}> <${intervalType}> .
    ?intervalNode <${intervalToStart}> ?startNode .
    ?startNode  <${type}> <${dateTimeValueType}> .
    ?startNode  <${dateTimeValue}> ?startField-value .
    ?startNode  <${dateTimePrecision}> ?startField-precision .
</v:jsonset>

<v:jsonset var="n3ForEnd">
    ?role      <${roleToInterval}> ?intervalNode .
    ?intervalNode  <${type}> <${intervalType}> .
    ?intervalNode <${intervalToEnd}> ?endNode .
    ?endNode  <${type}> <${dateTimeValueType}> .
    ?endNode  <${dateTimeValue}> ?endField-value .
    ?endNode  <${dateTimePrecision}> ?endField-precision .
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

    "n3optional"    : [ "${newRoleTypeAssertion}" ],

    "newResources"  : { "roleUri" : "${defaultNamespace}" },

    "urisInScope"    : { },
    "literalsInScope": { },
    "urisOnForm"     : [ "personUri", "roleTypeUri" ],
    "literalsOnForm" : [ ],
    "filesOnForm"    : [ ],
    "sparqlForLiterals" : { },
    "sparqlForUris" : {  },
    "sparqlForExistingLiterals" : { },
    "sparqlForExistingUris" : { },
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
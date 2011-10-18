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
    public static String nodeToRifcsThingProp = "http://purl.org/ands/ontologies/vivo/RifcsThing";

    VitroRequest vreq = new VitroRequest(request);

    String subjectUri = vreq.getParameter("subjectUri");
    String predicateUri = vreq.getParameter("predicateUri");
    String objectUri = vreq.getParameter("objectUri");

	Individual obj = (Individual) request.getAttribute("object");

    EditMode mode = FrontEndEditingUtils.getEditMode(request, nodeToRifcsThingProp);

    if( mode == EditMode.ADD ) {
       %> <c:set var="editMode" value="add"/><%
    } else if(mode == EditMode.EDIT){
        // Because it's edit mode, we already know there's one and only one statement
        ObjectPropertyStatement ops = obj.getObjectPropertyStatements(nodeToRifcsThingProp).get(0);
        String rifcsThingUri = ops.getObjectURI();
        String forwardToIndividual = rifcsThingUri != null ? rifcsThingUri : objectUri;
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
<c:set var="rdf" value="<%= VitroVocabulary.RDF %>" />
<c:set var="vitro" value="<%= VitroVocabulary.vitroURI %>" />
<c:set var="label" value="${rdfs}label" />
<c:set var="infoResourceClassUri" value="${vivoCore}InformationResource" />

<v:jsonset var="n3ForNewRifcsThing">
    @prefix rdf:  <${rdf}> .
    ?roleUri rdf:type ?roleTypeUri .    
</v:jsonset>

<c:set var="rifcsTypeLiteralOptions">
    ["", "Select type"],
    [ "http://purl.org/ands/ontologies/vivo/ResearchData", "Research Data" ],
    [ "http://purl.org/ands/ontologies/vivo/ResearchCatalog", "Research Catalog" ],
    [ "http://purl.org/ands/ontologies/vivo/ResearchCollection", "Research Collection" ],
    [ "http://purl.org/ands/ontologies/vivo/ResearchRecordsCollection", "Research Records Collection" ]
    [ "http://purl.org/ands/ontologies/vivo/ResearchRepository", "Research Repository" ],
    [ "http://purl.org/ands/ontologies/vivo/ResearchDataset", "Research Dataset" ],
    [ "http://purl.org/ands/ontologies/vivo/Service", "Service" ],
    [ "http://purl.org/ands/ontologies/vivo/ServiceAnnotate", "Service Annotate" ]
    [ "http://purl.org/ands/ontologies/vivo/ServiceAssemble", "Service Assemble" ],
    [ "http://purl.org/ands/ontologies/vivo/ServiceCreate", "Service Create" ],
    [ "http://purl.org/ands/ontologies/vivo/ServiceGenerate", "Service Generate" ],
    [ "http://purl.org/ands/ontologies/vivo/ServiceHarvestOaipmh", "Service Harvest OAIPMH" ],
    [ "http://purl.org/ands/ontologies/vivo/ServiceReport", "Service Report" ],
    [ "http://purl.org/ands/ontologies/vivo/ServiceSearchHttp", "Service Search HTTP" ],
    [ "http://purl.org/ands/ontologies/vivo/ServiceSearchOpensearch", "Service Open Search" ],
    [ "http://purl.org/ands/ontologies/vivo/ServiceSearchSrw", "Service Search SRW" ],
    [ "http://purl.org/ands/ontologies/vivo/ServiceSearchZ3950", "Service Search z3950" ],
    [ "http://purl.org/ands/ontologies/vivo/ServiceSearchSru", "Service Search SRU" ],
    [ "http://purl.org/ands/ontologies/vivo/ServiceSyndicateAtom", "Service Syndicate Atom" ],
    [ "http://purl.org/ands/ontologies/vivo/ServiceSyndicateRss", "Service Syndicate Rss" ],
    [ "http://purl.org/ands/ontologies/vivo/ServiceTransform", "Service Transform" ]
</c:set>

<c:set var="editjson" scope="request">
{
    "formUrl" : "${formUrl}",
    "editKey" : "${editKey}",
    "urlPatternToReturnTo" : "/individual",

    "subject"   : ["subject", "${subjectUriJson}" ],
    "predicate" : ["predicate", "${predicateUriJson}" ],
    "object"    : ["rifcsThingUri", "${objectUriJson}", "URI" ],

    "n3required"    : [ ],

    "n3optional"    : [ ],

    "newResources"  : { },

    "urisInScope"    : { },
    "literalsInScope": { },
    "urisOnForm"     : [ "rifcsThingUri" ],
    "literalsOnForm" : [ "rifcsThingName" ],
    "filesOnForm"    : [ ],
    "sparqlForLiterals" : { },
    "sparqlForUris" : {  },
    "sparqlForExistingLiterals" : { },
    "sparqlForExistingUris" : { },
    "fields" : {
      "rifcsThingType" : {
         "newResource"      : "false",
         "validators"       : [ ],
         "optionsType"      : "HARDCODED_LITERALS",
         "literalOptions"   : [ ${rifcsTypeLiteralOptions} ],
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : [ "" ]
      },
      "rifcsThingUri" : {
         "newResource"      : "true",
         "validators"       : [ ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [ ],
         "predicateUri"     : "",
         "objectClassUri"   : "${rifcsThingClassUriJson}",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : [""]
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
    }    

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
        <c:set var="titleVerb" value="Add" />
        <c:set var="submitButtonText" value="RIF-CS Thing" />
    </c:when>
    <c:otherwise>
        <c:set var="titleVerb" value="Edit" />
        <c:set var="submitButtonText" value="Edit RIF-CS Thing" />
    </c:otherwise>
</c:choose>

<c:set var="requiredHint" value="<span class='requiredHint'> *</span>" />

<jsp:include page="${preForm}" />

<% if( mode == EditMode.ERROR ){ %>
 <div>This form is unable to handle the editing of this position because it is associated with
      multiple Position individuals.</div>
<% }else{ %>

<h2>${titleVerb} role entry for <%= subjectName %></h2>

<%@ include file="unsupportedBrowserMessage.jsp" %>

<%-- DO NOT CHANGE IDS, CLASSES, OR HTML STRUCTURE IN THIS FORM WITHOUT UNDERSTANDING THE IMPACT ON THE JAVASCRIPT! --%>
<form id="addRoleForm" class="customForm noIE67"  action="<c:url value="/edit/processRdfForm2.jsp"/>" >

    <p class="inline"><v:input type="select" label="RIF-CS Type ${requiredHint}" name="rifcsThingType" id="typeSelector" /></p>

    <div class="fullViewOnly">       
       
	   <p><v:input type="text" id="relatedIndLabel" name="rifcsThingName" label="RIF-CS Thing Name ${requiredHint}" cssClass="acSelector" size="50" /></p>

	    <div class="acSelection">
	        <%-- RY maybe make this a label and input field. See what looks best. --%>
	        <p class="inline"><label></label><span class="acSelectionInfo"></span> <a href="<c:url value="/individual?uri=" />" class="verifyMatch">(Verify this match)</a></p>
	        <input type="hidden" id="rifcsThingUri" name="rifcsThingUri" class="acUriReceiver" value="" /> <!-- Field value populated by JavaScript -->
	    </div>
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
    defaultTypeName: 'RIF-CS Thing' // used in repair mode to generate button text
};
</script>

<% } %>

<jsp:include page="${postForm}"/>
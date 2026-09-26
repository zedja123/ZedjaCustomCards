--
--Build Rider - Kiryu
--scripted by Zedja
local s,id=GetID()
local SET_BUILD_RIDER=0x1e04
local SET_BUILD_DRIVER=0x2e04
function s.initial_effect(c)
	--If you control no other monsters, this card can be treated as 2 materials for the Link Summon of a "Build Rider" monster
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.linkcon)
	e0:SetTarget(s.linktg)
	e0:SetOperation(s.linkop)
	e0:SetValue(SUMMON_TYPE_LINK)
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e0a:SetRange(LOCATION_MZONE)
	e0a:SetTargetRange(LOCATION_EXTRA,0)
	e0a:SetTarget(function(e,c) return c:IsSetCard(SET_BUILD_RIDER) and c:IsLinkMonster() and c:IsLink(2) end)
	e0a:SetLabelObject(e0)
	c:RegisterEffect(e0a)
	--If this card is Normal or Special Summoned: You can add 1 "Build Driver" Spell/Trap from your Deck to your hand
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,1))
	e1a:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetCountLimit(1,{id,0})
	e1a:SetTarget(s.thtg)
	e1a:SetOperation(s.thop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--If a "Build Rider" Link Monster you control leaves the field by battle or card effect: You can Special Summon this card from your GY, but banish it when it leaves the field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.selfspcon)
	e2:SetTarget(s.selfsptg)
	e2:SetOperation(s.selfspop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_BUILD_RIDER,SET_BUILD_DRIVER}
function s.linkcon(e,c,must,g,min,max)
	if c==nil then return true end
	local tp=c:GetControler()
	local mc=e:GetOwner()
	if not (mc:IsLocation(LOCATION_MZONE) and mc:IsFaceup() and mc:IsControler(tp)) then return false end
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)~=1 then return false end
	if must and (#must>1 or not must:IsContains(mc)) then return false end
	if g and not g:IsContains(mc) then return false end
	return mc:IsCanBeLinkMaterial(c,tp) and mc:IsSetCard(SET_BUILD_RIDER,c,SUMMON_TYPE_LINK,tp)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
function s.linktg(e,tp,eg,ep,ev,re,r,rp,chk,c,must,g,min,max)
	local mg=Group.FromCards(e:GetOwner())
	mg:KeepAlive()
	e:SetLabelObject(mg)
	return true
end
function s.linkop(e,tp,eg,ep,ev,re,r,rp,c,must,g,min,max)
	local mg=e:GetLabelObject()
	c:SetMaterial(mg)
	Duel.SendtoGrave(mg,REASON_MATERIAL|REASON_LINK)
	mg:DeleteGroup()
end
function s.thfilter(c)
	return c:IsSetCard(SET_BUILD_DRIVER) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousSetCard(SET_BUILD_RIDER) and (c:GetPreviousTypeOnField()&TYPE_LINK)~=0
		and c:IsReason(REASON_BATTLE|REASON_EFFECT)
end
function s.selfspcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.cfilter,1,nil,tp)
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		--Banish it when it leaves the field
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end

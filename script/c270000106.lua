--
--Wiccanthrope Reason
--scripted by Zedja
local s,id=GetID()
local SET_WICCANTHROPE=0xe01
function s.initial_effect(c)
	--Target up to 2 monsters you control; immediately after this effect resolves, Xyz Summon 1 "Wiccanthrope" Xyz Monster using only those monsters as material
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--If this card is banished: You can add 1 "Wiccanthrope" Spell from your Deck to your hand, except "Wiccanthrope Reason"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_WICCANTHROPE}
function s.matfilter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
function s.xyzfilter(c,tp,mg)
	return c:IsSetCard(SET_WICCANTHROPE) and c:IsType(TYPE_XYZ) and c:IsXyzSummonable(nil,mg,#mg,#mg)
		and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end
function s.rescon(sg,e,tp,mg)
	return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,tp,sg)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil,e)
	if chk==0 then return aux.SelectUnselectGroup(mg,e,tp,1,2,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(mg,e,tp,1,2,s.rescon,1,tp,HINTMSG_XMATERIAL,s.rescon)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetTargetCards(e):Filter(function(c) return c:IsFaceup() and c:IsControler(tp) end,nil)
	if #mg==0 then return end
	local xg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,tp,mg)
	if #xg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=xg:Select(tp,1,1,nil):GetFirst()
	Duel.XyzSummon(tp,sc,nil,mg,#mg,#mg)
end
function s.thfilter(c)
	return c:IsSetCard(SET_WICCANTHROPE) and c:IsSpell() and not c:IsCode(id) and c:IsAbleToHand()
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

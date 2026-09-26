--
--Lavoisier Buster Draco
--scripted by Zedja
local s,id=GetID()
local SET_LAVOISIER=0xe03
local CARD_LAVOISIER_YOUCAN=270000313
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner + 1+ non-Tuner monsters
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--Pendulum Summon procedure
	Pendulum.AddProcedure(c,false)
	--You cannot Pendulum Summon, except "Lavoisier" monsters. This effect cannot be negated
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.pendlimit)
	c:RegisterEffect(e1)
	--Once per turn: You can Fusion Summon 1 "Lavoisier Amazing Draco - YOUCAN" from your Extra Deck, by shuffling its materials from your field, GY, and/or face-up Extra Deck into the Deck
	local fusion_params={
		fusfilter=aux.FilterBoolFunction(Card.IsCode,CARD_LAVOISIER_YOUCAN),
		matfilter=Fusion.OnFieldMat(Card.IsAbleToDeck),
		extrafil=s.fextra,
		extraop=Fusion.ShuffleMaterial,
		extratg=s.fextratg
	}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(Fusion.SummonEffTG(fusion_params))
	e2:SetOperation(Fusion.SummonEffOP(fusion_params))
	c:RegisterEffect(e2)
	--If this card is Summoned: You can destroy 1 other card you control; add up to 2 "Lavoisier" monsters from your face-up Extra Deck to your hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,{id,0})
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	--You can place this card in your Pendulum Zone; during your Main Phase this turn, you can conduct 1 Pendulum Summon of a monster(s) in addition to your Pendulum Summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCost(s.pzcost)
	e4:SetTarget(s.exptg)
	e4:SetOperation(s.expop)
	c:RegisterEffect(e4)
end
s.listed_names={CARD_LAVOISIER_YOUCAN}
s.listed_series={SET_LAVOISIER}
function s.pendlimit(e,c,sump,sumtype,sumpos,targetp)
	return (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM and not c:IsSetCard(SET_LAVOISIER)
end
function s.fexfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsAbleToDeck()
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(aux.NecroValleyFilter(s.fexfilter),tp,LOCATION_GRAVE|LOCATION_EXTRA,0,nil)
end
function s.fextratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_EXTRA)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDestructable,tp,LOCATION_ONFIELD,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,LOCATION_ONFIELD,0,1,1,c)
	Duel.Destroy(g,REASON_COST)
end
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_LAVOISIER) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_EXTRA,0,1,2,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.pzcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckPendulumZones(tp) and not c:IsForbidden() end
	Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
end
function s.exptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Pendulum.PlayerCanGainAdditionalPendulumSummon(tp,id) end
end
function s.expop(e,tp,eg,ep,ev,re,r,rp)
	--During your Main Phase this turn, you can conduct 1 Pendulum Summon of a monster(s) in addition to your Pendulum Summon
	Pendulum.GrantAdditionalPendulumSummon(e:GetHandler(),nil,tp,LOCATION_HAND|LOCATION_EXTRA,aux.Stringid(id,3),aux.Stringid(id,4),id)
end
